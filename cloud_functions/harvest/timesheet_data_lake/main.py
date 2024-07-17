import asyncio
import os
import pandas as pd
from google.cloud import bigquery
from datetime import datetime, timezone, date

from data_pipeline_tools.asyncs import get_data_for_page_range
from data_pipeline_tools.auth import harvest_headers
# from data_pipeline_tools.state import (
#     state_get,
#     state_update
# )
from data_pipeline_tools.util import (
    find_and_flatten_columns,
    get_harvest_pages,
    write_to_bigquery,
)

project_id = os.environ.get("GOOGLE_CLOUD_PROJECT")

if not project_id:
    project_id = "tpx-dx-dashboards"

progress_table = "tpx-dx-dashboards.State.process_state"

def state_get(id):
  client = bigquery.Client()

  query = f"SELECT next_page, UNIX_SECONDS(updated_since) as updated_since, UNIX_SECONDS(batch_start_time) as batch_start_time FROM `{progress_table}` WHERE id = '{id}'"
  query_job = client.query(query)
  result = list(query_job.result())

  for row in result:
      return row.next_page, row.updated_since, row.batch_start_time

  return None, None, None

def state_update(id, next_page, updated_since, batch_start_time):
    client = bigquery.Client()

    now = int(round(datetime.now(timezone.utc).timestamp()))

    page_update = "page_number = page_number + 1"

    if not next_page:
        updated_since = batch_start_time
        batch_start_time = now
        page_update = "page_number = 0"


    if not batch_start_time:
        batch_start_time = now

    last_processed_time = now


    if updated_since:
        query = f"""
            UPDATE `{progress_table}`
            SET
                next_page = '{next_page}',
                batch_start_time = TIMESTAMP_SECONDS({batch_start_time}),
                updated_since = TIMESTAMP_SECONDS({updated_since}),
                last_processed_time = TIMESTAMP_SECONDS({last_processed_time}),
                {page_update}
            WHERE id = '{id}'
        """
    else :
        query = f"""
            UPDATE `{progress_table}`
            SET
                next_page = '{next_page}',
                batch_start_time = TIMESTAMP_SECONDS({batch_start_time}),
                last_processed_time = TIMESTAMP_SECONDS({last_processed_time}),
                {page_update}
            WHERE id = '{id}'
        """

    print(query)

    query_job = client.query(query)
    query_job.result()

def load_config(project_id, service) -> dict:
    return {
        "url": "https://api.harvestapp.com/v2/time_entries",
        "headers": harvest_headers(project_id, service),
        "dataset_id": os.environ.get("DATASET_ID"),
        "gcp_project": project_id,
        "table_name": os.environ.get("TABLE_NAME"),
        "state_table_name": os.environ.get("STATE_TABLE_NAME"),
        "location": os.environ.get("TABLE_LOCATION"),
        "service": service
    }


def main(data: dict, context):
    service = "Data Pipeline - Harvest Timesheet Data Lake"
    config = load_config(project_id, service)
    batch_size = 1

    next_page, updated_since, batch_start_time = state_get(config["table_name"])

    print("current state", next_page, updated_since, batch_start_time)

    if updated_since:
        updated_since_iso = datetime.fromtimestamp(updated_since, timezone.utc).strftime('%Y-%m-%dT%H:%M:%SZ')
        url = config["url"] + f"?updated_since={updated_since_iso}&page="
    else:
        url = config["url"] + "?page="

    pages, entries = get_harvest_pages(url, config["headers"])

    print(f"Total pages: {pages}")

    for start_page in range(1, pages + 1, batch_size):
        end_page = min(start_page + batch_size - 1, pages)
        print(f"Getting pages {start_page} to {end_page}")

        df = asyncio.run(
            get_data_for_page_range(url, start_page, end_page, config["headers"], "time_entries")
        )

        if df.empty:
           break

        df["unique_id"] = df["id"].astype(str) + "-" + df["updated_at"].astype(str)

        write_to_bigquery(config, df, "WRITE_APPEND")

        break

    state_update(config["table_name"], "", updated_since, batch_start_time)

if __name__ == "__main__":
    main({}, None)
