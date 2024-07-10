import os
import pandas as pd
import requests
import time
from data_pipeline_tools.auth import runn_headers
from data_pipeline_tools.util import write_to_bigquery
from google.api_core.exceptions import Conflict, BadRequest
from datetime import datetime, timezone, date
from google.cloud import bigquery
import re

project_id = os.environ.get("GOOGLE_CLOUD_PROJECT")
project_id = "tpx-dx-dashboards"
service = "Data Pipeline - Actuals"
progress_table = "tpx-dx-dashboards.Runn_Processed.progress_actuals"
progress_state_id = "actuals_state"

if not project_id:
    project_id = input("Enter GCP project ID: ")

def write_runn_data_to_bigquery(config: dict, data: list) -> None:
    # Create a BigQuery client with the specified location.
    client = bigquery.Client(location=config["location"])

    dataset_id = config["dataset_id"]
    table_name = config["table_name"]

    # Get a reference to the BigQuery table to write to.
    dataset_ref = client.dataset(dataset_id)
    table_ref = dataset_ref.table(table_name)

    df = pd.DataFrame(data)
    
    if df.empty:
        print("No data to process.")
        return
    
    # Get the existing IDs before the merge
    query = f"SELECT id FROM `{dataset_id}.{table_name}`"
    existing_ids = {row["id"] for row in client.query(query)}

    # Split the data into records to update and records to insert
    records_to_update = df[df['id'].isin(existing_ids)]
    records_to_insert = df[~df['id'].isin(existing_ids)]

    print(f"Records to insert {len(records_to_insert)} records")
    print(f"Records to update {len(records_to_update)} records")

    total_processed = 0

    try:
        if not records_to_insert.empty:
            insert_df = pd.DataFrame(records_to_insert)
            insert_job_config = bigquery.LoadJobConfig(write_disposition="WRITE_APPEND")
            insert_job_config.autodetect = True

            insert_job = client.load_table_from_dataframe(insert_df, table_ref, job_config=insert_job_config)
            insert_job.result()
            print(f"Inserted {len(records_to_insert)} new rows into {table_ref}")
            total_processed += len(records_to_insert)

        if not records_to_update.empty:
            print(f"Updating data in target table {dataset_id}.{table_name}, total to update {len(records_to_update)} records")

            # Create a temporary table for the records to update
            temp_table_name = f"{table_name}_temp"
            temp_table_ref = dataset_ref.table(temp_table_name)

            # Load the records to update into a temporary table
            temp_job_config = bigquery.LoadJobConfig(write_disposition="WRITE_TRUNCATE")
            temp_job_config.autodetect = True

            temp_job = client.load_table_from_dataframe(records_to_update, temp_table_ref, job_config=temp_job_config)
            temp_job.result()

            print(f"Loaded {len(records_to_update)} records into temporary table {temp_table_ref}")

            # Generate the dynamic columns for the MERGE statement
            columns = records_to_update.columns.tolist()
            update_set = ", ".join([f"T.{col} = S.{col}" for col in columns])

            # Construct the merge query
            merge_query = f"""
            MERGE `{dataset_id}.{table_name}` T
            USING `{dataset_id}.{temp_table_name}` S
            ON T.id = S.id
            WHEN MATCHED THEN
                UPDATE SET {update_set}
            """

            try:
                merge_job = client.query(merge_query)
                merge_job.result()
                print(f"Updated {len(records_to_update)} rows in {table_ref}")
                total_processed += len(records_to_update)
            except BadRequest as e:
                print(f"Error merging DataFrame to BigQuery BadRequest: {str(e)}")
                return
            finally:
                # Clean up the temporary table
                client.delete_table(temp_table_ref, not_found_ok=True)
                print(f"Deleted temporary table {temp_table_ref}")

    except BadRequest as e:
        print(f"Error writing DataFrame to BigQuery BadRequest: {str(e)}")
        return

    except Exception as e:
        print(f"Error writing DataFrame to BigQuery Exception: {str(e)}")
        return
    # Print a message indicating how many rows were loaded.
    print(f"Processed {total_processed} rows.")


def load_config(project_id, service, nextCursor, modifiedAfter) -> dict:
    url ="https://api.runn.io/actuals/?limit=500"

    # If modifiedAfter is provided, add it to the query URL
    if modifiedAfter:
        url += f"&modifiedAfter={modifiedAfter}"
    
    if nextCursor:
        url += f"&cursor={nextCursor}"

    print(url, "API")

    return {
        "url": url,
        "headers": runn_headers(project_id, service),
        "dataset_id": "Runn_Raw",  # os.environ.get("DATASET_ID"),
        "gcp_project": project_id,
        "table_name": "actuals",  # os.environ.get("TABLE_NAME"),
        "location": "europe-west2",  # os.environ.get("TABLE_LOCATION"),
        "service": service,
    }


def update_progress(progress_table, start_process_time, last_processed_time, last_processed_cursor, id, last_successful_write, completed):
    client = bigquery.Client()

    # Check if a record with the given id exists
    query = f"SELECT id FROM `{progress_table}` WHERE id = '{id}'"
    query_job = client.query(query)
    result = list(query_job.result())

    # Convert Python None to SQL NULL and boolean to SQL TRUE/FALSE
    start_process_time_sql = 'NULL' if start_process_time is None else f"'{start_process_time.strftime('%Y-%m-%d %H:%M:%S')}'"
    last_processed_cursor_sql = 'NULL' if last_processed_cursor is None else f"'{last_processed_cursor}'"
    last_successful_write_sql = 'NULL' if last_successful_write is None else f"'{last_successful_write}'"
    completion_status = 'TRUE' if completed else 'FALSE'

    if len(result) > 0:
        print("Updating actuals progress state.")
        # If record exists, update it
        query = f"""
            UPDATE `{progress_table}`
            SET 
                last_processed_cursor = {last_processed_cursor_sql},
                start_process_time = {start_process_time_sql},
                last_processed_time = '{last_processed_time}',
                last_successful_write = {last_successful_write_sql},
                completed = {completion_status}
            WHERE id = '{id}'
        """
    else:
        print("Inserting actuals progress state.")
        # If record does not exist, insert a new one
        query = f"""
            INSERT INTO `{progress_table}` (id, start_process_time, last_processed_cursor, last_processed_time, last_successful_write, completed)
            VALUES ('{id}', '{start_time}', {last_processed_cursor_sql}, '{last_processed_time}', {last_successful_write_sql}, {completed})
        """

    query_job = client.query(query)
    query_job.result()

    print("Actuals progress state updated successfully.")


def get_last_processed_cursor(progress_table, id):
    client = bigquery.Client()

    query = f"SELECT last_processed_cursor, last_successful_write, start_process_time FROM `{progress_table}` WHERE id = '{id}'"
    query_job = client.query(query)
    result = list(query_job.result())

    for row in result:
        return row.last_processed_cursor, row.last_successful_write, row.start_process_time
    return None, None, None

def handle_rate_limits(response):
    rate_limit_remaining = int(response.headers.get("x-ratelimit-remaining", 1))
    rate_limit_reset = int(response.headers.get("x-ratelimit-reset", 0))
    retry_after = int(response.headers.get("retry-after", 0))

    print(f"Rate Limit remaining: {rate_limit_remaining}")
    print(f"Rate Limit time to reset: {rate_limit_reset}")
    print(f"Retry after: {retry_after}")

    if rate_limit_remaining == 0:
        wait_time = max(rate_limit_reset, retry_after)
        print(f"Rate limit reached. Waiting for {wait_time} seconds.")
        time.sleep(wait_time)

def main(data: dict, context):
    # Initialize nextCursor
    next_cursor, last_successful_write, start_process_time  = get_last_processed_cursor(progress_table, progress_state_id)
    nextCursor =  next_cursor if next_cursor and next_cursor != "None" else ""

    if not nextCursor:
        timestamp=datetime.now(timezone.utc).timestamp()
        start_process_time = datetime.fromtimestamp(timestamp)
    
    modifiedAfter_dt = last_successful_write.strftime("%Y-%m-%dT%H:%M:%SZ") if last_successful_write is not None else ""
    modifiedAfter = re.sub(r':', '%3A', modifiedAfter_dt)

    config = load_config(project_id, service, nextCursor, modifiedAfter)

    while True:
        config = load_config(project_id, service, nextCursor, modifiedAfter)
        response = requests.get(url=config["url"], headers=config["headers"])
        if response.status_code == 200:
            actuals = []
            data = response.json()
            handle_rate_limits(response)
            actuals.extend(data.get("values", []))
            nextCursor = data.get("nextCursor")
            write_runn_data_to_bigquery(config, actuals)

            timestamp=datetime.now(timezone.utc).timestamp()
            last_processed_time = datetime.fromtimestamp(timestamp)
            update_progress(progress_table, start_process_time, last_processed_time, nextCursor, progress_state_id, last_successful_write, False)

            if not nextCursor:
                print("No more actuals to fetch")
                last_successful_write = start_process_time
                start_process_time = None
                update_progress(progress_table, start_process_time, last_processed_time, nextCursor, progress_state_id, last_successful_write, True)
                break
        else:
            raise Exception(
                f"Failed to fetch actuals: {response.status_code}, {response.text}"
            )

    print("Done")

if __name__ == "__main__":
    main({}, None)
