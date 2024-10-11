import os
import pandas as pd
import requests
import time
import copy
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

from google.cloud import bigquery

project_id = os.environ.get("GOOGLE_CLOUD_PROJECT")

if not project_id:
    project_id = "tpx-dx-dashboards"

if not project_id:
    project_id = input("Enter GCP project ID: ")


def load_config(project_id, service) -> dict:
  return {
    "url": "https://api.runn.io/assignments",
    "headers": runn_headers(project_id, service),
    "dataset_id": "Runn_Raw",
#     "dataset_id": os.environ.get("DATASET_ID"),
    "gcp_project": project_id,
#     "table_name": os.environ.get("TABLE_NAME"),
    "table_name": "assignments_new",
#     "state_table_name": os.environ.get("PROCESS_TABLE_NAME"),
    "process_table_name": "assignments_process_table",
    "location": "europe-west2",
#     "location": os.environ.get("TABLE_LOCATION"),
    "service": service,
  }


def date_pd_timestamp(dateString):
  return pd.Timestamp(dateString)

def spent_date_pd_timestamp(dateString):
  return pd.Timestamp(f"{dateString}T00:00:00Z")

def number_days(item):
  return np.busday_count(
   datetime.strptime(item["startDate"], "%Y-%m-%d").date(),
   datetime.strptime(item["endDate"], "%Y-%m-%d").date()
 )

def process_dataframe(df):
  df["uniqueId"] = df["id"].astype(str) + "-" + df["startDate"].astype(str) + "-" + df["updatedAt"].astype(str)
  df["importDate"] = datetime.now(timezone.utc).strftime('%Y-%m-%dT%H:%M:%SZ')
  df["numberDays"] = df.apply(number_days, axis=1)
  df["workstreamId"] = df.apply(lambda x: 0, axis=1)

  df["startDate"] = df["startDate"].apply(spent_date_pd_timestamp)
  df["endDate"] = df["endDate"].apply(spent_date_pd_timestamp)
  df["createdAt"] = df["createdAt"].apply(date_pd_timestamp)
  df["updatedAt"] = df["updatedAt"].apply(date_pd_timestamp)
  df["importDate"] = df["importDate"].apply(date_pd_timestamp)
  df["isDeleted"] = False

  return df

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

def process_response(response, config, bigquery_client, should_truncate):
  if response.status_code == 200:
    data = response.json()
    next_cursor = data.get("nextCursor")

    df = pd.DataFrame(data.get("values", []))
    df = process_dataframe(df)

    if should_truncate:
      write_to_bigquery_local(bigquery_client, config["dataset_id"], config["process_table_name"], df, "WRITE_TRUNCATE")
    else:
      write_to_bigquery_local(bigquery_client, config["dataset_id"], config["process_table_name"], df, "WRITE_APPEND")

    return next_cursor
  else:
    raise Exception("Invalid API response")


def write_new_records(bigquery_client, config):
  query = f"""
    INSERT `{config["dataset_id"]}.{config["table_name"]}`
    SELECT
      new_items.*
    FROM `{config["dataset_id"]}.{config["process_table_name"]}` AS new_items
    LEFT JOIN `{config["dataset_id"]}.{config["table_name"]}` AS existing_items ON new_items.uniqueId = existing_items.uniqueId
    WHERE existing_items.id IS NULL
  """

  result = bigquery_client.query_and_wait(query)
  print(f"{result.num_dml_affected_rows} new records written")

def write_deleted_records(bigquery_client, config, start_date):
  query = f"""
    INSERT `{config["dataset_id"]}.{config["table_name"]}`
    SELECT
      existing_items.id,
      existing_items.personId,
      existing_items.startDate,
      existing_items.endDate,
      existing_items.projectId,
      existing_items.minutesPerDay,
      existing_items.roleId,
      existing_items.isActive,
      existing_items.note,
      existing_items.isBillable,
      existing_items.phaseId,
      existing_items.isNonWorkingDay,
      existing_items.isTemplate,
      existing_items.isPlaceholder,
      existing_items.workstreamId,
      existing_items.createdAt,
      CURRENT_TIMESTAMP() AS updatedAt,
      CONCAT(existing_items.id, "-", existing_items.startDate, "-", CURRENT_TIMESTAMP()) AS uniqueId,
      CURRENT_TIMESTAMP() AS importDate,
      0 AS numberDays,
      TRUE AS isDeleted
    FROM (
      SELECT
        assignments.*
      FROM `{config["dataset_id"]}.{config["table_name"]}` AS assignments
      JOIN (
        SELECT
        id,
        MAX(updatedAt) AS updatedAt
      FROM `{config["dataset_id"]}.{config["table_name"]}`
      WHERE EXTRACT(DATETIME FROM endDate) >= DATETIME("{start_date}")
      GROUP BY id
      ) AS ids ON assignments.id = ids.id AND assignments.updatedAt = ids.updatedAt
    ) AS existing_items
    LEFT JOIN `{config["dataset_id"]}.{config["process_table_name"]}` AS new_items ON existing_items.id = new_items.id
    WHERE new_items.id IS NULL AND existing_items.isDeleted <> TRUE
  """

  result = bigquery_client.query_and_wait(query)
  print(f"{result.num_dml_affected_rows} records marked as deleted")

def main(data: dict, context):
    service = "Data Pipeline - Runn assignments"
    config = load_config(project_id, service)

    bigquery_client = bigquery.Client(
      location=config["location"]
    )

    start_date = (datetime.today() - timedelta(weeks=4)).strftime("%Y-%m-%d")

    print(f"start_date: {start_date}")
    next_cursor = None
    page = 1

    url = config["url"] + f"?limit=500&startDate={start_date}"

    response = requests.get(url=url, headers=config["headers"])
    next_cursor = process_response(response, config, bigquery_client, True)

    while(next_cursor):
      url = config["url"] + f"?limit=500&cursor={next_cursor}&startDate={start_date}"
      response = requests.get(url=url, headers=config["headers"])
      next_cursor = process_response(response, config, bigquery_client, False)
      page += 1

    print("count", page, page * 500)

    write_new_records(bigquery_client, config)
    write_deleted_records(bigquery_client, config, start_date)

if __name__ == "__main__":
    main({}, None)
