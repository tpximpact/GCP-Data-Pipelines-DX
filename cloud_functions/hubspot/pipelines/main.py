import os
from hubspot import HubSpot
from hubspot.crm.deals import ApiException
import pandas as pd
from data_pipeline_tools.util import (
    write_to_bigquery,
    target_daily_partition,
)
from data_pipeline_tools.auth import access_secret_version
from datetime import datetime, timezone

MAX_ATTEMPTS = 5

project_id = os.environ.get("GOOGLE_CLOUD_PROJECT") or "tpx-dx-dashboards"


def fetch_all_pipelines(api_client, attempt=0):
    try:
        response = api_client.crm.pipelines.pipelines_api.get_all("deal")
        return response.results
    except ApiException as e:
        print(f"Exception occured when requesting pipeliens: {e}")
        if attempt < MAX_ATTEMPTS:
            print("Retrying... attempt {attempt}")
            return fetch_all_pipelines(api_client, attempt + 1)
        else:
            print("Error: Too many retries")
            raise e


def load_config(project_id, service, ingest_time) -> dict:
    return {
        "dataset_id": os.environ.get("DATASET_ID") or "Hubspot_Raw",
        "gcp_project": project_id,
        "table_name": target_daily_partition(
            os.environ.get("TABLE_NAME") or "hubspot_pipelines", ingest_time
        ),
        "location": os.environ.get("TABLE_LOCATION") or "europe-west2",
        "service": service,
    }


def process_df(df):
    df["id"] = df["id"].astype(str)
    df["archived"] = df["archived"].astype(bool)
    df["archived_at"] = df["archived_at"].apply(pd.Timestamp)
    df["label"] = df["label"].astype(str)
    df["created_at"] = df["created_at"].apply(pd.Timestamp)
    df["updated_at"] = df["updated_at"].apply(pd.Timestamp)

    df = df[
        [
            "id",
            "archived",
            "archived_at",
            "label",
            "created_at",
            "updated_at",
        ]
    ]

    return df


def main(data: dict, context: dict = None):
    service = "Data Pipeline - HubSpot pipelines"
    hubspot_token = access_secret_version(project_id, "HUBSPOT_TOKEN")

    api_client = HubSpot(access_token=hubspot_token)
    now = datetime.now(timezone.utc)
    config = load_config(project_id, service, now)

    try:
        companies = fetch_all_pipelines(api_client)
        df = pd.DataFrame([company.to_dict() for company in companies])
        processed = process_df(df)

        write_to_bigquery(config, processed, "WRITE_TRUNCATE_DATA")

    except ApiException as e:
        print("Exception when calling pipelines_api->get: %s\n" % e)


if __name__ == "__main__":
    main({})
