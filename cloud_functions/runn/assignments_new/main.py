import os
import pandas as pd
import requests
import time
import copy
import sys
import numpy as np
from datetime import datetime, timezone, date, timedelta

from data_pipeline_tools.auth import runn_headers
from data_pipeline_tools.util import (
  handle_runn_rate_limits,
  write_to_bigquery
)

from data_pipeline_tools.state import (
    state_get,
    state_update
)

project_id = os.environ.get("GOOGLE_CLOUD_PROJECT")

if not project_id:
    project_id = "tpx-dx-dashboards"

if not project_id:
    project_id = input("Enter GCP project ID: ")


def load_config(project_id, service) -> dict:
    return {
        "url": "https://api.runn.io/assignments",
        "headers": runn_headers(project_id, service),
        # "dataset_id": 'Runn_Raw',
        "dataset_id": os.environ.get("DATASET_ID"),
        "gcp_project": project_id,
        # "table_name": 'assignments_new',
        "table_name": os.environ.get("TABLE_NAME"),
        "state_table_name": os.environ.get("STATE_TABLE_NAME"),
        "location": os.environ.get("TABLE_LOCATION"),
        "service": service,
    }


def date_to_timestamp(date_string) -> float:
    parsed_date = datetime.fromisoformat(date_string[:-1])
    return int(round(parsed_date.timestamp()))


def process_response(response, list):
  print("response.status_code", response.status_code)
  print("response", response)

  if response.status_code == 200:
    data = response.json()
    next_cursor = data.get("nextCursor")

    for i in data.get("values", []):
      list.append(i)

    return list, next_cursor
  else:
    raise Exception("Invalid API response")

def date_pd_timestamp(dateString):
    return pd.Timestamp(dateString)

def number_days(item):
    return np.busday_count(
     datetime.strptime(item["startDate"], "%Y-%m-%d").date(),
     datetime.strptime(item["endDate"], "%Y-%m-%d").date()
   )


def process_dataframe(df):
  df["uniqueId"] = df["id"].astype(str) + "-" + df["startDate"].astype(str) + "-" + df["updatedAt"].astype(str)
  df["importDate"] = datetime.now(timezone.utc).strftime('%Y-%m-%dT%H:%M:%SZ')
  df["numberDays"] = df.apply(number_days, axis=1)

  print(df["startDate"].min(), df["startDate"].max())

  df["startDate"] = df["startDate"].apply(date_pd_timestamp)
  df["endDate"] = df["endDate"].apply(date_pd_timestamp)
  df["createdAt"] = df["createdAt"].apply(date_pd_timestamp)
  df["updatedAt"] = df["updatedAt"].apply(date_pd_timestamp)
  df["importDate"] = df["importDate"].apply(date_pd_timestamp)

  return df

def process_response_import_only(response, config):
  if response.status_code == 200:
    data = response.json()
    next_cursor = data.get("nextCursor")

    df = pd.DataFrame(data.get("values", []))
    df = process_dataframe(df)

    # write_to_bigquery(config, df, "WRITE_APPEND")

    return next_cursor
  else:
    raise Exception("Invalid API response")


def main(data: dict, context):
    service = "Data Pipeline - Runn assignments"
    config = load_config(project_id, service)

    start_date = (datetime.today() - timedelta(weeks=4)).strftime("%Y-%m-%d")
    # Do we want to use end date too?
    # I guess so, fewer queries, fewer resources, etc...
    end_date   = datetime.today().strftime("%Y-%m-%d")

    next_cursor = None
    page = 1

    url = config["url"] + f"?limit=500&startDate={start_date}&endDate={end_date}"

    response = requests.get(url=url, headers=config["headers"])

    next_cursor = process_response_import_only(response, config)

    while(next_cursor):
      url = config["url"] + f"?limit=500&cursor={next_cursor}&startDate={start_date}&endDate={end_date}"
      response = requests.get(url=url, headers=config["headers"])
      next_cursor = process_response_import_only(response, config)
      page += 1

    print("count", page, page * 500)

if __name__ == "__main__":
    main({}, None)
