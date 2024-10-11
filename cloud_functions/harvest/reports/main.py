import os
import requests
import pandas as pd
from google.cloud import bigquery
from datetime import datetime, timezone, date, timedelta

from data_pipeline_tools.auth import harvest_headers

from data_pipeline_tools.util import (
    find_and_flatten_columns,
    get_harvest_pages,
    write_to_bigquery,
)


project_id = os.environ.get("GOOGLE_CLOUD_PROJECT")

if not project_id:
    project_id = "tpx-dx-dashboards"


def load_config(project_id, service) -> dict:
  return {
    "url": "https://api.harvestapp.com/v2/reports/time/projects",
    "headers": harvest_headers(project_id, service),
    "dataset_id": os.environ.get("DATASET_ID") if os.environ.get("DATASET_ID") else "Harvest_Raw",
    "gcp_project": project_id,
    "table_name": os.environ.get("TABLE_NAME") if os.environ.get("TABLE_NAME") else "reports" ,
    "location": os.environ.get("TABLE_LOCATION"),
    "service": service
  }

def date_pd_timestamp(dateString):
  return pd.Timestamp(dateString)


def spent_date_pd_timestamp(dateString):
  return pd.Timestamp(f"{dateString}T00:00:00Z")

def write_to_bigquery_local(client: bigquery.Client, dataset_id: str, table_name: str, df: pd.DataFrame, write_disposition: str) -> None:

   # Get a reference to the BigQuery table to write to.
  dataset_ref = client.dataset(dataset_id)
  table_ref = dataset_ref.table(table_name)

  # Set up the job configuration with the specified write disposition.
  job_config = bigquery.LoadJobConfig(write_disposition=write_disposition)
  job_config.autodetect = True

  try:
    # Write the DataFrame to BigQuery using the specified configuration.
    job = client.load_table_from_dataframe(df, table_ref, job_config=job_config)
    job.result()
  except BadRequest as e:
    print(f"Error writing DataFrame to BigQuery: {str(e)}")
    return

  # Print a message indicating how many rows were loaded.
  print(
    "Loaded {} rows into {}:{}.".format(
      job.output_rows, dataset_id, table_name
    )
  )

def process_dataframe(df):
  df["unique_id"] = df["id"].astype(str) + "-" + df["updated_at"].astype(str)
  df["import_date"] = datetime.now(timezone.utc).strftime('%Y-%m-%dT%H:%M:%SZ')

  df["spent_date"] = df["spent_date"].apply(spent_date_pd_timestamp)
  df["created_at"] = df["created_at"].apply(date_pd_timestamp)
  df["updated_at"] = df["updated_at"].apply(date_pd_timestamp)
  df["import_date"] = df["import_date"].apply(date_pd_timestamp)

  drop_columns = ["invoice", "started_time", "ended_time", "timer_started_at"]

  if "external_reference" in df.columns:
    drop_columns.append("external_reference")

  if "user_assignment" in df.columns:
    drop_columns.append("user_assignment")

  if "task_assignment" in df.columns:
    drop_columns.append("task_assignment")

  df = df.drop(columns=drop_columns)

  df = find_and_flatten_columns(df)

  df["is_deleted"] = False

  return df

def process_response(response, config, bigquery_client, should_truncate):
  if response.status_code == 200:
    data = response.json()
    next_page = data.get("next_page")


    df = pd.DataFrame(data.get("results", []))

    print("df.size", df.size)


#     df = process_dataframe(df)

    if  df.size:
      if should_truncate:
        write_to_bigquery_local(bigquery_client, config["dataset_id"], config["table_name"], df, "WRITE_TRUNCATE")
      else:
        write_to_bigquery_local(bigquery_client, config["dataset_id"], config["table_name"], df, "WRITE_APPEND")


    return next_page
  else:
    print(response.status_code)
    print(response.json())

    raise Exception("Invalid API response")

def report_get_for_year(year, config, headers, bigquery_client):
  start_date = date(year, 1, 1).strftime("%Y-%m-%d")
  end_date = date(year, 12, 31).strftime("%Y-%m-%d")

#   print("start_date", start_date)
#   print("end_date", end_date)

  url = f"{config["url"]}?from={start_date}&to={end_date}"
  print("url", url)

  response = requests.get(url=url, headers=headers)
  next_page = process_response(response, config, bigquery_client, False)

  page = 1

  while(next_page):
    url = f"{config["url"]}?from={start_date}&to={end_date}&page={next_page}"

    print("url", url)

    response = requests.get(url=url, headers=headers)
    next_page = process_response(response, config, bigquery_client, False)
    page += 1

  print("Total page", page)


def main(data: dict, context):
    service = "Data Pipeline - Harvest Timesheet Data Lake"
    config = load_config(project_id, service)
    bigquery_client = bigquery.Client(location=config["location"])

    token = "3671714.pt.T-ilOXNu3mbDB2i-h7fALFfTBFGNelPyCSkSNG6YYikyU_PFy7Bve9wi_mqQo_GohKsn4uu46yqAECHtY9Q7og"
    year = 2020

    headers = {
      "Harvest-Account-ID": "1640103",
      "Authorization": f"Bearer {token}",
      "User-Agent": "TPX Cloud Functions",
      "Content-Type": "application/json"
    }

    result = bigquery_client.query_and_wait(
      f"""
        TRUNCATE TABLE `{config["dataset_id"]}.{config["table_name"]}`
      """
    )

    while (year <= datetime.now().year):
      report_get_for_year(year=year, config=config, headers=headers, bigquery_client=bigquery_client)
      year += 1

    # 42.19


if __name__ == "__main__":
    main({}, None)