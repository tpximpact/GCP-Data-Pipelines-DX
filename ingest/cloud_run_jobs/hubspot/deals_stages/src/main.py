from __future__ import annotations

from dotenv import load_dotenv
import os
from datetime import datetime, timezone
from typing import Any, cast

import pandas as pd
from hubspot import HubSpot
from hubspot.crm.pipelines import ApiException

from data_pipeline_tools.util import (
    find_and_flatten_columns,
    target_daily_partition,
    write_to_bigquery,
)


load_dotenv()

PROJECT_ID = os.environ["GOOGLE_CLOUD_PROJECT"]
DATASET_ID = "Hubspot_Raw"
TABLE_NAME = "hubspot_deals_stages"
SERVICE_NAME = "Data Pipeline - HubSpot deals stages"
TABLE_LOCATION = os.environ["TABLE_LOCATION"]
HUBSPOT_TOKEN = os.environ["HUBSPOT_TOKEN"]


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
    df["pipeline_id"] = df["pipeline_id"].astype(str)
    df["pipeline_title"] = df["pipeline_title"].astype(str)
    df["metadata_isClosed"] = df["metadata_isClosed"].astype(bool)
    df["metadata_probability"] = pd.to_numeric(df["metadata_probability"], errors="coerce")
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
                "pipeline_id",
                "pipeline_title",
                "metadata_isClosed",
                "metadata_probability",
                "created_at",
                "updated_at",
            ]
        ].copy(),
    )

    return ordered_df


def main(data: dict[str, Any] | None = None, context: object | None = None) -> None:
    del data, context

    ingest_time = datetime.now(timezone.utc)
    config = load_config(PROJECT_ID, SERVICE_NAME, ingest_time)
    api_client = HubSpot(access_token=HUBSPOT_TOKEN)

    try:
        api_response = api_client.crm.pipelines.pipelines_api.get_all(object_type="deals")
        pipelines = [pipeline.to_dict() for pipeline in api_response.results]

        processed_pipelines: list[dict[str, Any]] = []
        for pipeline in pipelines:
            pipeline_id = pipeline["id"]
            pipeline_title = pipeline.get("label", "Unknown")
            for stage in pipeline["stages"]:
                processed_pipelines.append(
                    {
                        **stage,
                        "pipeline_id": pipeline_id,
                        "pipeline_title": pipeline_title,
                    }
                )

        df = pd.DataFrame(processed_pipelines)
        df = find_and_flatten_columns(df)
        ordered_df = process_dataframe(df)
        write_to_bigquery(config, ordered_df, "WRITE_TRUNCATE_DATA")
    except ApiException as error:  # pragma: no cover
        print(f"Exception when calling pipelines_api->get_all: {error}")


if __name__ == "__main__":  # pragma: no cover
    main({}, None)
