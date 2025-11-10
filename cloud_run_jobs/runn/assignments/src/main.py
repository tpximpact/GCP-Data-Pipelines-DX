import os
from datetime import datetime, timezone
from itertools import batched
from typing import cast

import pandas as pd

from data_pipeline_tools.auth import access_secret_version, runn_headers
from data_pipeline_tools.bigquery_helpers import bigquery_client_get, write_to_bigquery
from data_pipeline_tools.runn_tools import fetch_all
from data_pipeline_tools.util import target_daily_partition

BATCH_SIZE = 50
project_id = os.environ.get("GOOGLE_CLOUD_PROJECT") or "tpx-dx-dashboards"
service = "Data Pipeline - Assignments"


def load_config(project_id: str, service: str, ingest_time: datetime) -> dict:
    return {
        "headers": runn_headers(project_id, service),
        "dataset_id": os.environ.get("DATASET_ID") or "Runn_Raw",
        "gcp_project": project_id,
        "table_name": target_daily_partition(
            os.environ.get("TABLE_NAME") or "assignments", ingest_time
        ),
        "location": os.environ.get("TABLE_LOCATION") or "europe-west2",
        "service": service,
    }


def _to_datetime(date_string: str) -> pd.Timestamp:
    return pd.Timestamp(date_string)


def _to_midnight_timestamp(date_string: str) -> pd.Timestamp:
    return pd.Timestamp(f"{date_string}T00:00:00Z")


def process_dataframe(df: pd.DataFrame) -> pd.DataFrame:
    now_iso = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")

    df["uniqueId"] = df["id"].astype(str) + "-" + df["updatedAt"].astype(str)
    df["importDate"] = now_iso
    df["workstreamId"] = 0
    df["phaseId"] = pd.to_numeric(df["phaseId"], errors="coerce")

    df["startDate"] = df["startDate"].apply(_to_midnight_timestamp)
    df["endDate"] = df["endDate"].apply(_to_midnight_timestamp)
    df["createdAt"] = df["createdAt"].apply(_to_datetime)
    df["updatedAt"] = df["updatedAt"].apply(_to_datetime)
    df["importDate"] = df["importDate"].apply(_to_datetime)

    ordered_df = cast(
        pd.DataFrame,
        df.loc[
            :,
            [
                "uniqueId",
                "id",
                "personId",
                "projectId",
                "roleId",
                "phaseId",
                "startDate",
                "endDate",
                "minutesPerDay",
                "isActive",
                "note",
                "isBillable",
                "isNonWorkingDay",
                "isTemplate",
                "isPlaceholder",
                "workstreamId",
                "createdAt",
                "updatedAt",
                "importDate",
            ],
        ].copy(),
    )

    return ordered_df


def main(data: dict | None = None, context: object | None = None) -> None:
    now = datetime.now(timezone.utc)
    config = load_config(project_id, service, now)

    runn_api_token = access_secret_version(project_id, "RUNN_ACCESS_TOKEN")
    bigquery_client = bigquery_client_get(location=config["location"])

    pages = fetch_all(
        token=runn_api_token,
        base_url="https://api.runn.io/assignments/",
        service=service,
        page_size=200,
    )

    for batch_num, batch in enumerate(batched(pages, BATCH_SIZE)):
        write_disposition = "WRITE_TRUNCATE_DATA" if batch_num == 0 else "WRITE_APPEND"

        df = pd.concat(batch)
        processed_df = process_dataframe(df)

        write_to_bigquery(
            client=bigquery_client,
            dataset_id=config["dataset_id"],
            table_name=config["table_name"],
            df=processed_df,
            write_disposition=write_disposition,
        )


if __name__ == "__main__":
    main({}, None)
