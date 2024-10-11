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

from data_pipeline_tools.state import (
    state_get,
    state_update
)

from google.cloud import bigquery

project_id = os.environ.get("GOOGLE_CLOUD_PROJECT")

if not project_id:
    project_id = "tpx-dx-dashboards"

if not project_id:
    project_id = input("Enter GCP project ID: ")


def load_config(project_id, service) -> dict:
  return {
    "headers": runn_headers(project_id, service),
    "dataset_id": os.environ.get("DATASET_ID") if os.environ.get("DATASET_ID") else "Runn_Processed",
    "gcp_project": project_id,
    "destination_table_name": os.environ.get("DESTINATION_TABLE_NAME") if os.environ.get("DESTINATION_TABLE_NAME") else "assignments_latest_by_day",
    "source_table_name": os.environ.get("SOURCE_TABLE_NAME") if os.environ.get("SOURCE_TABLE_NAME") else "assignments_latest_new",
    "location": os.environ.get("TABLE_LOCATION") if os.environ.get("TABLE_LOCATION") else  "europe-west2",
    "service": service,
  }

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

def main(data: dict, context):
  service = "Data Pipeline - Runn assignments split by day"
  config = load_config(project_id, service)

  offset = 0
  limit = 2000
  has_next = True

  bigquery_client = bigquery.Client(
    location=config["location"]
  )

  while has_next:
    print(f"Getting rows {offset} to {offset + limit}")

    query = f"""
      SELECT
        assignments.*,
        roles.standardRate AS standard_rate
      FROM {config["dataset_id"]}.{config["source_table_name"]} AS assignments
      LEFT JOIN `Runn_Raw.roles` AS roles ON assignments.role_id = roles.id
      ORDER BY start_date LIMIT {limit} OFFSET {offset}
    """

    rows = read_from_bigquery(project_id, query)
    has_next = len(rows.index) > 0

    rows = expand_rows(rows)
    rows["unique_id"] = rows["id"].astype(str) + "-" + rows["start_date"].astype(str) + "-" + rows["updated_at"].astype(str)
    rows = rows.drop(columns=['end_date'])

    write_to_bigquery_local(
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
  rows_to_edit = df[df["start_date"] != df["end_date"]]
  single_assignment_rows = df[df["start_date"] == df["end_date"]]
  edited_rows = []

  for _, row in rows_to_edit.iterrows():
    # get the times

    dates = get_dates(row["start_date"], row["end_date"])

    for date in dates:
      new_row = copy.copy(row)
      new_row["start_date"] = date
      new_row["end_date"] = date
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
