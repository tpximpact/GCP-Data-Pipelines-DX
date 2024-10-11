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
    "url": "https://api.harvestapp.com/v2/time_entries",
    "headers": harvest_headers(project_id, service),
    "dataset_id": os.environ.get("DATASET_ID") if os.environ.get("DATASET_ID") else "Harvest_Raw",
    "gcp_project": project_id,
    "table_name": os.environ.get("TABLE_NAME") if os.environ.get("TABLE_NAME") else "timesheet_data_lake_new" ,
    "process_table_name": os.environ.get("PROCESS_TABLE_NAME") if os.environ.get("PROCESS_TABLE_NAME") else "timesheet_data_lake_process_table" ,
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
#   job_config.autodetect = True

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

    df = pd.DataFrame(data.get("time_entries", []))
    df = process_dataframe(df)

    if should_truncate:
      write_to_bigquery_local(bigquery_client, config["dataset_id"], config["process_table_name"], df, "WRITE_TRUNCATE")
    else:
      write_to_bigquery_local(bigquery_client, config["dataset_id"], config["process_table_name"], df, "WRITE_APPEND")


    return next_page
  else:
    print(response.status_code)
    print(response.json())

    raise Exception("Invalid API response")

def write_deleted_records(bigquery_client, config, start_date):
  query = f"""
    INSERT `{config["dataset_id"]}.{config["table_name"]}`
      (
        id,
        spent_date,
        hours,
        hours_without_timer,
        rounded_hours,
        notes,
        is_locked,
        locked_reason,
        is_closed,
        is_billed,
        is_running,
        billable,
        budgeted,
        billable_rate,
        cost_rate,
        created_at,
        updated_at,
        unique_id,
        import_date,
        user_id,
        user_name,
        client_id,
        client_name,
        client_currency,
        project_id,
        project_name,
        project_code,
        task_id,
        task_name,
        is_deleted
      )
    SELECT
      existing_items.id,
      existing_items.spent_date,
      existing_items.hours,
      existing_items.hours_without_timer,
      existing_items.rounded_hours,
      existing_items.notes,
      existing_items.is_locked,
      existing_items.locked_reason,
      existing_items.is_closed,
      existing_items.is_billed,
      existing_items.is_running,
      existing_items.billable,
      existing_items.budgeted,
      existing_items.billable_rate,
      existing_items.cost_rate,
      existing_items.created_at,
      CURRENT_TIMESTAMP() AS updated_at,
      CONCAT(existing_items.id, "-", existing_items.spent_date, "-", CURRENT_TIMESTAMP()) AS unique_id,
      CURRENT_TIMESTAMP() AS import_date,
      existing_items.user_id,
      existing_items.user_name,
      existing_items.client_id,
      existing_items.client_name,
      existing_items.client_currency,
      existing_items.project_id,
      existing_items.project_name,
      existing_items.project_code,
      existing_items.task_id,
      existing_items.task_name,
      TRUE AS is_deleted
    FROM (
      SELECT
        timesheets.*
      FROM `Harvest_Raw.timesheet_data_lake_new` AS timesheets
      JOIN (
        SELECT
          id,
          MAX(updated_at) AS updated_at
        FROM `Harvest_Raw.timesheet_data_lake_new`
        WHERE EXTRACT(DATETIME FROM spent_date) >= DATETIME("{start_date}")
        GROUP BY id
      ) AS ids ON timesheets.id = ids.id AND timesheets.updated_at = ids.updated_at
    ) AS existing_items
    LEFT JOIN `Harvest_Raw.timesheet_data_lake_process_table` AS new_items ON existing_items.id = new_items.id
    WHERE new_items.id IS NULL AND existing_items.is_deleted <> TRUE
  """

  result = bigquery_client.query_and_wait(query)
  print(f"{result.num_dml_affected_rows} records marked as deleted")


def write_new_records(bigquery_client, config):
  query = f"""
    INSERT `{config["dataset_id"]}.{config["table_name"]}`
      (
        id,
        spent_date,
        hours,
        hours_without_timer,
        rounded_hours,
        notes,
        is_locked,
        locked_reason,
        is_closed,
        is_billed,
        is_running,
        billable,
        budgeted,
        billable_rate,
        cost_rate,
        created_at,
        updated_at,
        unique_id,
        import_date,
        user_id,
        user_name,
        client_id,
        client_name,
        client_currency,
        project_id,
        project_name,
        project_code,
        task_id,
        task_name,
        is_deleted
      )
    SELECT
      new_items.id,
      new_items.spent_date,
      new_items.hours,
      new_items.hours_without_timer,
      new_items.rounded_hours,
      new_items.notes,
      new_items.is_locked,
      new_items.locked_reason,
      new_items.is_closed,
      new_items.is_billed,
      new_items.is_running,
      new_items.billable,
      new_items.budgeted,
      new_items.billable_rate,
      new_items.cost_rate,
      new_items.created_at,
      new_items.updated_at,
      new_items.unique_id,
      new_items.import_date,
      new_items.user_id,
      new_items.user_name,
      new_items.client_id,
      new_items.client_name,
      new_items.client_currency,
      new_items.project_id,
      new_items.project_name,
      new_items.project_code,
      new_items.task_id,
      new_items.task_name,
      new_items.is_deleted
    FROM `{config["dataset_id"]}.{config["process_table_name"]}` AS new_items
    LEFT JOIN `{config["dataset_id"]}.{config["table_name"]}` AS existing_items ON new_items.unique_id = existing_items.unique_id
    WHERE existing_items.id IS NULL
  """

  result = bigquery_client.query_and_wait(query)
  print(f"{result.num_dml_affected_rows} new records written")

def main(data: dict, context):
    service = "Data Pipeline - Harvest Timesheet Data Lake"
    config = load_config(project_id, service)
    bigquery_client = bigquery.Client(location=config["location"])

    token = "3671714.pt.T-ilOXNu3mbDB2i-h7fALFfTBFGNelPyCSkSNG6YYikyU_PFy7Bve9wi_mqQo_GohKsn4uu46yqAECHtY9Q7og"

    start_date = (datetime.today() - timedelta(weeks=6)).strftime("%Y-%m-%d")
    url = f"{config["url"]}?from={start_date}"
    url = f"{config["url"]}"

    print("start_date", start_date)
    print("url", url)

    headers = {
      "Harvest-Account-ID": "1640103",
      "Authorization": f"Bearer {token}",
      "User-Agent": "TPX Cloud Functions",
      "Content-Type": "application/json"
    }

    response = requests.get(url=url, headers=headers)
    next_page = process_response(response, config, bigquery_client, True)

    page = 1

    while(next_page):
      url = f"{config["url"]}?from={start_date}&page={next_page}"
      url = f"{config["url"]}?page={next_page}"

      print("url", url)

      response = requests.get(url=url, headers=headers)
      next_page = process_response(response, config, bigquery_client, False)
      page += 1

    print("count", page, page * 2000)

    write_deleted_records(bigquery_client, config, start_date)
    write_new_records(bigquery_client, config)

if __name__ == "__main__":
    main({}, None)