import os
import pandas as pd
from dotenv import load_dotenv
from data_pipeline_tools.bigquery_helpers import bigquery_client_get, write_to_bigquery
from data_pipeline_tools.auth import runn_headers
from data_pipeline_tools.util import target_daily_partition
from data_pipeline_tools.runn_tools import fetch_all
from datetime import datetime, timezone
from itertools import batched

load_dotenv()

PROJECT_ID = os.environ["GOOGLE_CLOUD_PROJECT"]
DATASET_ID = "Runn_Raw"
TABLE_NAME = "actuals"
SERVICE_NAME = "Data Pipeline - HubSpot companies"
TABLE_LOCATION = os.environ["TABLE_LOCATION"]
RUNN_API_TOKEN = os.environ["RUNN_API_TOKEN"]

SERVICE = "Data Pipeline - Actuals"

BATCH_SIZE = 50


def load_config(project_id, service, ingest_time) -> dict:
    return {
        "headers": runn_headers(project_id, service),
        "dataset_id": DATASET_ID,
        "gcp_project": project_id,
        "table_name": target_daily_partition(
            TABLE_NAME, ingest_time
        ),
        "location": TABLE_LOCATION,
        "service": service,
    }


def process_dataframe(df):
    df["importDate"] = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
    df["date"] = df["date"].apply(
        lambda dateString: pd.Timestamp(f"{dateString}T00:00:00Z")
    )
    df["createdAt"] = df["createdAt"].apply(pd.Timestamp)
    df["updatedAt"] = df["updatedAt"].apply(pd.Timestamp)
    df["importDate"] = df["importDate"].apply(pd.Timestamp)
    return df


def main(data: dict, context):
    now = datetime.now(timezone.utc)
    config = load_config(PROJECT_ID, SERVICE, now)

    bigquery_client = bigquery_client_get(location=config["location"])

    pages = fetch_all(
        token=RUNN_API_TOKEN,
        base_url="https://api.runn.io/actuals/",
        service=SERVICE,
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
