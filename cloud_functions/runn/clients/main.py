import os
import pandas as pd
import requests
import time
import copy
from datetime import datetime, timezone, date, timedelta

from data_pipeline_tools.auth import runn_headers
from data_pipeline_tools.util import write_to_bigquery
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
        "url": "https://api.runn.io/clients",
        "headers": runn_headers(project_id, service),
        "dataset_id": os.environ.get("DATASET_ID"),
        "gcp_project": project_id,
        "table_name": os.environ.get("TABLE_NAME"),
        "state_table_name": os.environ.get("STATE_TABLE_NAME"),
        "location": os.environ.get("TABLE_LOCATION"),
        "service": service,
    }


def harvest_id_get(references: list):
  harvest_id =""

  for row in references:
    if row["referenceName"] == "Harvest":
      harvest_id = row["externalId"]

  return harvest_id


def page_get(url, headers):
  print("getting page", url)
  response = requests.get(url=url, headers=headers)

  if response.status_code == 200:
    data = response.json()
    next_cursor = data.get("nextCursor")

    df = pd.DataFrame(data.get("values", []))

    if df.empty:
      return df, ""

    df["harvest_id"] = df["references"].apply(harvest_id_get)
    df = df.drop(columns=["references"])

    return df, next_cursor

  else:
    raise Exception(f"Failed to fetch assignments: {response.status_code}, {response.text}")


def main(data: dict, context):
    service = "Data Pipeline - Clients"
    config = load_config(project_id, service)

    next_cursor = ""
    has_more = True
    df = pd.DataFrame([])

    while has_more:
      if next_cursor:
        url = config["url"] + f"?cursor={next_cursor}"
      else:
         url = config["url"]


      page_df, next_cursor = page_get(url, headers=config["headers"])

      df = pd.concat([df, page_df])

      if not next_cursor:
        has_more = False
        break

    print("DF SIZE final", len(df))

    write_to_bigquery(config, df, "WRITE_TRUNCATE")


if __name__ == "__main__":
    main({}, None)
