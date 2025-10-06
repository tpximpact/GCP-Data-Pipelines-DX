import os
import pandas as pd
from data_pipeline_tools.auth import access_secret_version
from data_pipeline_tools.util import (
    write_to_bigquery,
    find_and_flatten_columns,
    target_daily_partition,
)
from hubspot import HubSpot
from hubspot.crm.pipelines import ApiException
from datetime import datetime, timezone

project_id = os.environ.get("GOOGLE_CLOUD_PROJECT") or "tpx-dx-dashboards"


def load_config(project_id, service, ingest_time) -> dict:
    return {
        "dataset_id": os.environ.get("DATASET_ID") or "Hubspot_Raw",
        "gcp_project": project_id,
        "table_name": target_daily_partition(
            os.environ.get("TABLE_NAME") or "hubspot_deals_stages", ingest_time
        ),
        "location": os.environ.get("TABLE_LOCATION"),
        "service": service,
    }


def process_dataframe(df):
    df["id"] = df["id"].astype(str)
    df["archived"] = df["archived"].astype(bool)
    df["archived_at"] = df["archived_at"].apply(pd.Timestamp)
    df["label"] = df["label"].astype(str)
    df["pipeline_id"] = df["pipeline_id"].astype(str)
    df["pipeline_title"] = df["pipeline_title"].astype(str)
    df["metadata_isClosed"] = df["metadata_isClosed"].astype(bool)
    df["metadata_probability"] = pd.to_numeric(
        df["metadata_probability"], errors="coerce"
    )
    df["created_at"] = df["created_at"].apply(pd.Timestamp)
    df["updated_at"] = df["updated_at"].apply(pd.Timestamp)

    df = df[
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
    ]

    return df


def main(data: dict, context: dict = None):
    service = "Data Pipeline - HubSpot deals"
    now = datetime.now(timezone.utc)
    config = load_config(project_id, service, now)
    hubspot_token = access_secret_version(project_id, "HUBSPOT_TOKEN")
    api_client = HubSpot(access_token=hubspot_token)
    try:
        api_response = api_client.crm.pipelines.pipelines_api.get_all(
            object_type="deals"
        )
        pipelines = [x.to_dict() for x in api_response.results]

        processed_pipelines = []
        for pipeline in pipelines:
            pipeline_id = pipeline["id"]
            pipeline_title = pipeline.get("label", "Unknown")
            for stage in pipeline["stages"]:
                row = {
                    **stage,
                    "pipeline_id": pipeline_id,
                    "pipeline_title": pipeline_title,
                }
                processed_pipelines.append(row)

        df = pd.DataFrame(processed_pipelines)
        df = find_and_flatten_columns(df)
        df = process_dataframe(df)
        write_to_bigquery(config, df, "WRITE_TRUNCATE_DATA")

    except ApiException as e:
        print("Exception when calling pipelines_api->get_all: %s\n" % e)


if __name__ == "__main__":
    main({})
