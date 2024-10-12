import os
import pandas as pd
import requests

from datetime import datetime, timezone
from data_pipeline_tools.auth import runn_headers

from data_pipeline_tools.bigquery_helpers import (
  bigquery_client_get,
  write_to_bigquery
)

project_id = os.environ.get("GOOGLE_CLOUD_PROJECT")

if not project_id:
  project_id = "tpx-dx-dashboards"

if not project_id:
  project_id = input("Enter GCP project ID: ")


def load_config(project_id, service) -> dict:
  return {
    "url"        : "https://api.runn.io/assignments?limit=500",
    "headers"    : runn_headers(project_id, service),
    "dataset_id" : os.environ.get("DATASET_ID") if os.environ.get("DATASET_ID") else "Runn_Raw",
    "gcp_project": project_id,
    "table_name" : os.environ.get("TABLE_NAME") if os.environ.get("TABLE_NAME") else "assignments",
    "location"   : os.environ.get("TABLE_LOCATION") if os.environ.get("TABLE_LOCATION") else "europe-west2",
    "service"    : service,
  }

def date_pd_timestamp(dateString):
  return pd.Timestamp(dateString)

def spent_date_pd_timestamp(dateString):
  return pd.Timestamp(f"{dateString}T00:00:00Z")


def process_dataframe(df):
  df["uniqueId"]     = df["id"].astype(str) + "-" + df["updatedAt"].astype(str)
  df["importDate"]   = datetime.now(timezone.utc).strftime('%Y-%m-%dT%H:%M:%SZ')
  df["workstreamId"] = df.apply(lambda x: 0, axis=1)

  df["phaseId"] = df["phaseId"].astype(float)

  df["startDate"]  = df["startDate"].apply(spent_date_pd_timestamp)
  df["endDate"]    = df["endDate"].apply(spent_date_pd_timestamp)
  df["createdAt"]  = df["createdAt"].apply(date_pd_timestamp)
  df["updatedAt"]  = df["updatedAt"].apply(date_pd_timestamp)
  df["importDate"] = df["importDate"].apply(date_pd_timestamp)

  df = df[[
    'uniqueId',
    'id',
    'personId',
    'projectId',
    'roleId',
    'phaseId',
    'startDate',
    'endDate',
    'minutesPerDay',
    'isActive',
    'note',
    'isBillable',
    'isNonWorkingDay',
    'isTemplate',
    'isPlaceholder',
    'workstreamId',
    'createdAt',
    'updatedAt',
    'importDate'
  ]]

  return df

def process_response(response, config):
  if response.status_code == 200:
    data = response.json()
    next_cursor = data.get("nextCursor")

    df = pd.DataFrame(data.get("values", []))
    df = process_dataframe(df)

    return next_cursor, df
  else:
    print(response.status_code)

    raise Exception("Invalid API response")


def main(data: dict, context):
  service         = "Data Pipeline - Runn assignments"
  config          = load_config(project_id, service)
  bigquery_client = bigquery_client_get(location=config["location"])
  next_cursor     = None
  page            = 1
  url             = config["url"]

  response = requests.get(url=url, headers=config["headers"])
  next_cursor, df = process_response(response, config=config)

  write_to_bigquery(
    client=bigquery_client,
    dataset_id=config["dataset_id"],
    table_name=config["table_name"],
    df=df,
    write_disposition="WRITE_TRUNCATE"
  )

  storeDf = pd.DataFrame([])

  while(next_cursor):
    print("Processing page", page)

    response = requests.get(url=f"{url}&cursor={next_cursor}", headers=config["headers"])
    next_cursor, df = process_response(response, config=config)

    if len(storeDf.index) > 0:
      storeDf = pd.concat([storeDf, df])
    else:
      storeDf = df

    print("store length", len(storeDf.index), len(df.index))

    if len(storeDf.index) == 4000:
      write_to_bigquery(
        client=bigquery_client,
        dataset_id=config["dataset_id"],
        table_name=config["table_name"],
        df=storeDf,
        write_disposition="WRITE_APPEND"
      )

      storeDf = pd.DataFrame([])

    page += 1

  if len(storeDf.index) > 0:
    write_to_bigquery(
      client=bigquery_client,
      dataset_id=config["dataset_id"],
      table_name=config["table_name"],
      df=storeDf,
      write_disposition="WRITE_APPEND"
    )


  print("count", page, page * 500)


if __name__ == "__main__":
    main({}, None)
