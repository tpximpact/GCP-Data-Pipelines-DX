from __future__ import annotations

import os
from datetime import datetime, timezone
from typing import Any, cast

import pandas as pd
from hubspot import HubSpot
from hubspot.crm.companies import ApiException

from data_pipeline_tools.auth import access_secret_version
from data_pipeline_tools.util import (
    find_and_flatten_columns,
    target_daily_partition,
    write_to_bigquery,
)

PROJECT_ID = os.environ.get("GOOGLE_CLOUD_PROJECT") or "tpx-dx-dashboards"
SERVICE_NAME = "Data Pipeline - HubSpot companies"


def fetch_all_companies(api_client: HubSpot) -> list[dict[str, Any]]:
    all_companies: list[dict[str, Any]] = []
    after: str | None = None

    while True:
        try:
            response = api_client.crm.companies.basic_api.get_page(
                limit=100,
                after=after,
                properties=[
                    "name",
                    "createdate",
                    "sector_team",
                    "sub_sector",
                ],
            )
            all_companies.extend([company.to_dict() for company in response.results])

            after = response.paging.next.after if response.paging and response.paging.next else None
            if not after:
                break
        except ApiException as error:  # pragma: no cover - defensive logging
            print(f"Exception when requesting companies: {error}")
            break

    return all_companies


def load_config(project_id: str, service: str, ingest_time: datetime) -> dict[str, Any]:
    return {
        "dataset_id": os.environ.get("DATASET_ID") or "Hubspot_Raw",
        "gcp_project": project_id,
        "table_name": target_daily_partition(
            os.environ.get("TABLE_NAME") or "hubspot_companies", ingest_time
        ),
        "location": os.environ.get("TABLE_LOCATION") or "europe-west2",
        "service": service,
    }


def main(data: dict[str, Any] | None = None, context: object | None = None) -> None:
    del data, context

    hubspot_token = access_secret_version(PROJECT_ID, "HUBSPOT_TOKEN")
    api_client = HubSpot(access_token=hubspot_token)

    ingest_time = datetime.now(timezone.utc)
    config = load_config(PROJECT_ID, SERVICE_NAME, ingest_time)

    try:
        companies = fetch_all_companies(api_client)
        df = pd.DataFrame(companies)

        df = find_and_flatten_columns(df)
        df["id"] = df["id"].astype("Int64")
        df["archived"] = df["archived"].astype(bool)
        df["archived_at"] = df["archived_at"].apply(pd.Timestamp)
        df["properties_name"] = df["properties_name"].astype(str)
        df["properties_sector_team"] = df["properties_sector_team"].astype(str)
        df["properties_sub_sector"] = df["properties_sub_sector"].astype(str)

        df["unique_id"] = df["id"].astype(str) + "-" + df["updated_at"].astype(str)
        df["created_at"] = df["created_at"].apply(pd.Timestamp)
        df["updated_at"] = df["updated_at"].apply(pd.Timestamp)
        df["import_date"] = pd.Timestamp(ingest_time)

        ordered_df = df[
                [
                    "id",
                    "archived",
                    "archived_at",
                    "properties_name",
                    "properties_sub_sector",
                    "properties_sector_team",
                    "unique_id",
                    "created_at",
                    "updated_at",
                    "import_date",
                ]
            ]
        

        write_to_bigquery(config, ordered_df, "WRITE_TRUNCATE_DATA")
    except ApiException as error:  # pragma: no cover - defensive logging
        print(f"Exception when calling companies API: {error}")


if __name__ == "__main__":  # pragma: no cover - smoke tests rely on CLI entrypoint
    main({}, None)
