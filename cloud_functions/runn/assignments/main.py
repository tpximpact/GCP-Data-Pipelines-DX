import os
import pandas as pd
import requests

from datetime import datetime, timezone
from data_pipeline_tools.auth import runn_headers, access_secret_version

from data_pipeline_tools.bigquery_helpers import bigquery_client_get, write_to_bigquery
from data_pipeline_tools.util import target_daily_partition

from data_pipeline_tools.runn_tools import handle_runn_rate_limits
from data_pipeline_tools.runn_tools import fetch_all
from itertools import batched

BATCH_SIZE = 50

project_id = os.environ.get("GOOGLE_CLOUD_PROJECT") or "tpx-dx-dashboards"

if not project_id:
    project_id = "tpx-dx-dashboards"

if not project_id:
    project_id = input("Enter GCP project ID: ")


def load_config(project_id, service, ingest_time) -> dict:
    return {
        "headers": runn_headers(project_id, service),
        "dataset_id": (os.environ.get("DATASET_ID") or "Runn_Raw"),
        "gcp_project": project_id,
        "table_name": target_daily_partition(
            os.environ.get("TABLE_NAME") or "assignments", ingest_time
        ),
        "location": (os.environ.get("TABLE_LOCATION") or "europe-west2"),
        "service": service,
    }


def date_pd_timestamp(dateString):
    return pd.Timestamp(dateString)


def spent_date_pd_timestamp(dateString):
    return pd.Timestamp(f"{dateString}T00:00:00Z")


def process_dataframe(df):
    df["uniqueId"] = df["id"].astype(str) + "-" + df["updatedAt"].astype(str)
    df["importDate"] = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
    df["workstreamId"] = df.apply(lambda x: 0, axis=1)

    df["phaseId"] = df["phaseId"].astype(float)

    df["startDate"] = df["startDate"].apply(spent_date_pd_timestamp)
    df["endDate"] = df["endDate"].apply(spent_date_pd_timestamp)
    df["createdAt"] = df["createdAt"].apply(date_pd_timestamp)
    df["updatedAt"] = df["updatedAt"].apply(date_pd_timestamp)
    df["importDate"] = df["importDate"].apply(date_pd_timestamp)

    df = df[
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
        ]
    ]

    return df


def main(data: dict, context):
    service = "Data Pipeline - Assignments"
    now = datetime.now(timezone.utc)
    config = load_config(project_id, service, now)

    runn_api_token = access_secret_version(project_id, "RUNN_ACCESS_TOKEN")
    bigquery_client = bigquery_client_get(location=config["location"])

    pages = fetch_all(
        token=runn_api_token,
        base_url="https://api.runn.io/assignments/",
        service=service,
    )

    for batch_num, batch in enumerate(batched(pages, BATCH_SIZE)):
        # First frame truncates partition
        # Subsequent frames append
        disposition = "WRITE_TRUNCATE_DATA" if batch_num == 0 else "WRITE_APPEND"

        df = pd.concat(batch)

        processed_df = process_dataframe(df)
        write_to_bigquery(
            client=bigquery_client,
            dataset_id=config["dataset_id"],
            table_name=config["table_name"],
            df=processed_df,
            write_disposition=disposition,
        )


if __name__ == "__main__":
    main({}, None)
