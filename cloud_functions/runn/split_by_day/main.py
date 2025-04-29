import os
import pandas as pd
import requests
import time
import copy
import numpy as np
from datetime import datetime, timezone, date, timedelta

from data_pipeline_tools.auth import runn_headers
from data_pipeline_tools.util import (
  read_from_bigquery
)

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
    "headers"               :runn_headers(project_id, service),
    "dataset_id"            : os.environ.get("DATASET_ID") if os.environ.get("DATASET_ID") else "Runn_Raw",
    "gcp_project"           : project_id,
    "destination_table_name": os.environ.get("DESTINATION_TABLE_NAME") if os.environ.get("DESTINATION_TABLE_NAME") else "assignments_by_day",
    "source_table_name"     : os.environ.get("SOURCE_TABLE_NAME") if os.environ.get("SOURCE_TABLE_NAME") else "assignments",
    "location"              : os.environ.get("TABLE_LOCATION") if os.environ.get("TABLE_LOCATION") else  "europe-west2",
    "service"               : service,
  }

def main(data: dict, context):
  service = "Data Pipeline - Runn assignments split by day"
  config  = load_config(project_id, service)

  offset   = 0
  limit    = 2000
  has_next = True

  bigquery_client = bigquery_client_get(location=config["location"])

  while has_next:
    print(f"Getting rows {offset} to {offset + limit}")

    query = f"""
      SELECT
        assignments.*,
      FROM {config["dataset_id"]}.{config["source_table_name"]} AS assignments
      ORDER BY startDate LIMIT {limit} OFFSET {offset}
    """

    rows     = read_from_bigquery(project_id, query)
    has_next = len(rows.index) > 0

    rows             = expand_rows(rows)
    rows["uniqueId"] = rows["id"].astype(str) + "-" + rows["startDate"].astype(str) + "-" + rows["updatedAt"].astype(str)
    rows             = rows.drop(columns=['endDate'])

    write_to_bigquery(
      bigquery_client,
      config["dataset_id"],
      config["destination_table_name"],
      rows,
      "WRITE_TRUNCATE" if offset == 0 else "WRITE_APPEND"
    )

    offset += limit


def expand_rows(df):
  # When an assignment is entered, it can be put in for a single day or multiple.
  # For entries spanning across multiple days, this function converts to single day entries and returns the dataframe.
  rows_to_edit = df[df["startDate"] != df["endDate"]]
  single_assignment_rows = df[df["startDate"] == df["endDate"]]
  edited_rows = []

  for _, row in rows_to_edit.iterrows():
    # get the times

    dates = get_dates(row["startDate"], row["endDate"])

    for date in dates:
      new_row = copy.copy(row)
      new_row["startDate"] = date
      new_row["endDate"] = date
      edited_rows.append(new_row)

  return pd.concat([single_assignment_rows, pd.DataFrame(edited_rows)])


def get_dates(start_date: datetime, end_date: datetime) -> list:
  date = copy.copy(start_date)
  dates_list = []

  while date <= end_date:
    if date.weekday() < 5:
      dates_list.append(date)
    date = date + timedelta(days=1)
  return dates_list

if __name__ == "__main__":
    main({}, None)
