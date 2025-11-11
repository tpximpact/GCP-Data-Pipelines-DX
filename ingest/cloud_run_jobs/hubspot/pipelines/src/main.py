from __future__ import annotations

from dotenv import load_dotenv
import os
from datetime import datetime, timezone
from typing import Any, cast

import pandas as pd
from hubspot import HubSpot
from hubspot.crm.deals import ApiException

from data_pipeline_tools.util import target_daily_partition, write_to_bigquery


load_dotenv()

PROJECT_ID = os.environ["GOOGLE_CLOUD_PROJECT"]
DATASET_ID = "Hubspot_Raw"
TABLE_NAME = "hubspot_pipelines"
SERVICE_NAME = "Data Pipeline - HubSpot pipelines"
TABLE_LOCATION = os.environ["TABLE_LOCATION"]
HUBSPOT_TOKEN = os.environ["HUBSPOT_TOKEN"]
MAX_ATTEMPTS = 5


def fetch_all_pipelines(api_client: HubSpot, attempt: int = 0) -> list[Any]:
    try:
        response = api_client.crm.pipelines.pipelines_api.get_all("deal")
        return response.results
    except ApiException as error:  # pragma: no cover
        print(f"Exception occurred when requesting pipelines: {error}")
        if attempt < MAX_ATTEMPTS:
            print(f"Retrying... attempt {attempt + 1}")
            return fetch_all_pipelines(api_client, attempt + 1)
        print("Error: Too many retries")
        raise


def load_config(project_id: str, service: str, ingest_time: datetime) -> dict[str, Any]:
    return {
        "dataset_id": DATASET_ID,
        "gcp_project": project_id,
        "table_name": target_daily_partition(
            TABLE_NAME, ingest_time
        ),
        "location": TABLE_LOCATION,
        "service": service,
    }


def process_dataframe(df: pd.DataFrame) -> pd.DataFrame:
    df["id"] = df["id"].astype(str)
    df["archived"] = df["archived"].astype(bool)
    df["archived_at"] = df["archived_at"].apply(pd.Timestamp)
    df["label"] = df["label"].astype(str)
    df["created_at"] = df["created_at"].apply(pd.Timestamp)
    df["updated_at"] = df["updated_at"].apply(pd.Timestamp)

    ordered_df = cast(
        pd.DataFrame,
        df[
            [
                "id",
                "archived",
                "archived_at",
                "label",
                "created_at",
                "updated_at",
            ]
        ].copy(),
    )

    return ordered_df


def main(data: dict[str, Any] | None = None, context: object | None = None) -> None:
    del data, context

    api_client = HubSpot(access_token=HUBSPOT_TOKEN)

    ingest_time = datetime.now(timezone.utc)
    config = load_config(PROJECT_ID, SERVICE_NAME, ingest_time)

    try:
        pipelines = fetch_all_pipelines(api_client)
        df = pd.DataFrame([pipeline.to_dict() for pipeline in pipelines])
        processed_df = process_dataframe(df)
        write_to_bigquery(config, processed_df, "WRITE_TRUNCATE_DATA")
    except ApiException as error:  # pragma: no cover
        print(f"Exception when calling pipelines API: {error}")


if __name__ == "__main__":  # pragma: no cover
    main({}, None)
