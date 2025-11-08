import os
import pandas as pd
from data_pipeline_tools.bigquery_helpers import bigquery_client_get, write_to_bigquery
from data_pipeline_tools.auth import runn_headers, access_secret_version
from data_pipeline_tools.util import target_daily_partition
from data_pipeline_tools.runn_tools import fetch_all
from datetime import datetime, timezone
from itertools import batched


project_id = os.environ.get("GOOGLE_CLOUD_PROJECT") or "tpx-dx-dashboards"
service = "Data Pipeline - Placeholders"

BATCH_SIZE = 50


def load_config(project_id, service, ingest_time) -> dict:
    return {
        "headers": runn_headers(project_id, service),
        "dataset_id": (os.environ.get("DATASET_ID") or "Runn_Raw"),
        "gcp_project": project_id,
        "table_name": target_daily_partition(
            os.environ.get("TABLE_NAME") or "placeholders", ingest_time
        ),
        "location": (os.environ.get("TABLE_LOCATION") or "europe-west2"),
        "service": service,
    }


def process_dataframe(df):
    df["importDate"] = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")

    df["id"] = df["id"].astype("Int64")
    df["firstName"] = df["firstName"].astype(str)
    df["lastName"] = df["lastName"].astype(str)
    df["isArchived"] = df["isArchived"].astype(bool)

    df["createdAt"] = df["createdAt"].apply(pd.Timestamp)
    df["updatedAt"] = df["updatedAt"].apply(pd.Timestamp)
    df["importDate"] = df["importDate"].apply(pd.Timestamp)


    df = df[[
        "id",
        "firstName",
        "lastName",
        "isArchived",
        "createdAt",
        "updatedAt",
        ]
    ]
    return df


def main(data: dict, context):
    now = datetime.now(timezone.utc)
    config = load_config(project_id, service, now)

    runn_api_token = access_secret_version(project_id, "RUNN_ACCESS_TOKEN")
    bigquery_client = bigquery_client_get(location=config["location"])

    pages = fetch_all(
        token=runn_api_token,
        base_url="https://api.runn.io/placeholders/",
        service=service,
        page_size=200
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
