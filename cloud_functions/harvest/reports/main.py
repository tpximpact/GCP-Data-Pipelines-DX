import os
import requests
import pandas as pd
from datetime import datetime, timezone, date, timedelta

from data_pipeline_tools.auth import harvest_headers

from data_pipeline_tools.util import (
    find_and_flatten_columns,
    get_harvest_pages
)

from data_pipeline_tools.bigquery_helpers import (
  bigquery_client_get,
  write_to_bigquery
)

project_id = os.environ.get("GOOGLE_CLOUD_PROJECT")

if not project_id:
  project_id = "tpx-dx-dashboards"


def load_config(project_id, service) -> dict:
  return {
    "url"        : "https://api.harvestapp.com/v2/reports/time/projects",
    "headers"    : harvest_headers(project_id, service),
    "dataset_id" : os.environ.get("DATASET_ID") if os.environ.get("DATASET_ID") else "Harvest_Raw",
    "gcp_project": project_id,
    "table_name" : os.environ.get("TABLE_NAME") if os.environ.get("TABLE_NAME") else "reports",
    "location"   : os.environ.get("TABLE_LOCATION") if os.environ.get("TABLE_LOCATION") else "europe-west2",
    "service"    : service
  }

def process_response(response, config, bigquery_client, should_truncate):
  if response.status_code == 200:
    data      = response.json()
    next_page = data.get("next_page")
    df = pd.DataFrame(data.get("results", []))

    if  df.size:
      write_to_bigquery(
        client=bigquery_client,
        dataset_id=config["dataset_id"],
        table_name=config["table_name"],
        df=df,
        write_disposition="WRITE_TRUNCATE" if should_truncate else "WRITE_APPEND"
      )

    return next_page
  else:
    print(response.status_code)
    print(response.json())

    raise Exception("Invalid API response")

def report_get_for_year(year, config, bigquery_client, should_truncate):
  start_date = date(year, 1, 1).strftime("%Y-%m-%d")
  end_date   = date(year, 12, 31).strftime("%Y-%m-%d")

  url = f"{config["url"]}?from={start_date}&to={end_date}"
  print("url", url)

  response  = requests.get(url=url, headers=config["headers"])
  next_page = process_response(response, config, bigquery_client, should_truncate)

  page = 1

  while(next_page):
    url = f"{config["url"]}?from={start_date}&to={end_date}&page={next_page}"
    print("url", url)

    response  = requests.get(url=url, headers=headers)
    next_page = process_response(response, config, bigquery_client, should_truncate)
    page += 1

  print("Total pages", page)

def main(data: dict, context):
  service         = "Data Pipeline - Harvest Timesheet Data Lake"
  config          = load_config(project_id, service)
  bigquery_client = bigquery_client_get(location=config["location"])

  page = 0
  year = 2020

  while (year <= datetime.now().year):
    report_get_for_year(
      year=year, config=config,
      bigquery_client=bigquery_client,
      should_truncate=page == 0
    )

    year += 1
    page += 1

if __name__ == "__main__":
    main({}, None)