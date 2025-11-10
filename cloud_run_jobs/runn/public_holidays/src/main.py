import os
from datetime import datetime, timezone
from itertools import batched
from typing import Any, cast

import pandas as pd

from data_pipeline_tools.auth import access_secret_version, runn_headers
from data_pipeline_tools.bigquery_helpers import bigquery_client_get, write_to_bigquery
from data_pipeline_tools.runn_tools import fetch_all
from data_pipeline_tools.util import target_daily_partition

BATCH_SIZE = 50
project_id = os.environ.get("GOOGLE_CLOUD_PROJECT") or "tpx-dx-dashboards"
service = "Data Pipeline - Public Holidays"


def load_config(project_id: str, service: str) -> dict[str, Any]:
    return {
        "headers": runn_headers(project_id, service),
        "dataset_id": os.environ.get("DATASET_ID") or "Runn_Raw",
        "gcp_project": project_id,
        "table_name": os.environ.get("TABLE_NAME") or "public_holidays",
        "location": os.environ.get("TABLE_LOCATION") or "europe-west2",
        "service": service,
    }


def _to_midnight(date_string: str) -> pd.Timestamp:
    return pd.Timestamp(f"{date_string}T00:00:00Z")



def process_dataframe(df):
    df["uniqueId"] = df["id"].astype(str) + "-" + df["updatedAt"].astype(str)
    df["importDate"] = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")

    df["minutesPerDay"] = df["minutesPerDay"].apply(lambda x: x if x else 0)

    df["startDate"] = df["startDate"].apply(
        lambda dateString: pd.Timestamp(f"{dateString}T00:00:00Z")
    )
    df["endDate"] = df["endDate"].apply(
        lambda dateString: pd.Timestamp(f"{dateString}T00:00:00Z")
    )
    df["createdAt"] = df["createdAt"].apply(lambda dateString: pd.Timestamp(dateString))
    df["updatedAt"] = df["updatedAt"].apply(lambda dateString: pd.Timestamp(dateString))
    df["importDate"] = df["importDate"].apply(
        lambda dateString: pd.Timestamp(dateString)
    )

    df = df[
        [
            "uniqueId",
            "id",
            "personId",
            "holidayId",
            "startDate",
            "endDate",
            "minutesPerDay",
            "note",
            "createdAt",
            "updatedAt",
            "importDate",
        ]
    ]

    return df


def main(data: dict | None = None, context: object | None = None) -> None:
    now = datetime.now(timezone.utc)
    config = load_config(project_id, service)

    runn_api_token = access_secret_version(project_id, "RUNN_ACCESS_TOKEN")
    bigquery_client = bigquery_client_get(location=config["location"])

    pages = fetch_all(
        token=runn_api_token,
        base_url="https://api.runn.io/time-offs/holidays",
        service=service,
        page_size=200,
    )

    target_table = target_daily_partition(config["table_name"], now)

    for batch_num, batch in enumerate(batched(pages, BATCH_SIZE)):
        write_disposition = "WRITE_TRUNCATE_DATA" if batch_num == 0 else "WRITE_APPEND"

        df = pd.concat(batch)
        processed_df = process_dataframe(df)

        write_to_bigquery(
            client=bigquery_client,
            dataset_id=config["dataset_id"],
            table_name=target_table,
            df=processed_df,
            write_disposition=write_disposition,
        )


if __name__ == "__main__":
    main({}, None)
