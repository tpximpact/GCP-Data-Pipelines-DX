from __future__ import annotations

import os
from datetime import datetime, timezone
from typing import Any, cast

import pandas as pd
from hubspot import HubSpot
from hubspot.crm.deals import ApiException

from data_pipeline_tools.auth import access_secret_version
from data_pipeline_tools.util import target_daily_partition, write_to_bigquery

PROJECT_ID = os.environ.get("GOOGLE_CLOUD_PROJECT") or "tpx-dx-dashboards"
SERVICE_NAME = "Data Pipeline - HubSpot pipelines"
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
        "dataset_id": os.environ.get("DATASET_ID") or "Hubspot_Raw",
        "gcp_project": project_id,
        "table_name": target_daily_partition(
            os.environ.get("TABLE_NAME") or "hubspot_pipelines", ingest_time
        ),
        "location": os.environ.get("TABLE_LOCATION") or "europe-west2",
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

    hubspot_token = access_secret_version(PROJECT_ID, "HUBSPOT_TOKEN")
    api_client = HubSpot(access_token=hubspot_token)

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
