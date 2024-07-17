import asyncio
import os
import pandas as pd
from google.cloud import bigquery
from datetime import datetime, timezone, date

from data_pipeline_tools.asyncs import get_data_for_page_range
from data_pipeline_tools.auth import harvest_headers
from data_pipeline_tools.state import (
    state_get,
    state_update
)
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
    batch_size = 10

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

        df = df.drop(columns=["started_time", "ended_time"])
        df["unique_id"] = df["id"].astype(str) + "-" + df["updated_at"].astype(str)

        write_to_bigquery(config, df, "WRITE_APPEND")

    state_update(config["table_name"], "", batch_start_time, batch_start_time, true)

if __name__ == "__main__":
    main({}, None)
