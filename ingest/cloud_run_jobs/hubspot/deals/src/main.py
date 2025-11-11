from __future__ import annotations

from dotenv import load_dotenv
import os
from datetime import datetime, timezone
from typing import Any, Iterable, cast

import pandas as pd
from hubspot import HubSpot
from hubspot.crm.deals import ApiException

from data_pipeline_tools.util import target_daily_partition, write_to_bigquery


load_dotenv()

PROJECT_ID = os.environ["GOOGLE_CLOUD_PROJECT"]
DATASET_ID = "Hubspot_Raw"
TABLE_NAME = "hubspot_deals"
SERVICE_NAME = "Data Pipeline - HubSpot deals"
TABLE_LOCATION = os.environ["TABLE_LOCATION"]
HUBSPOT_TOKEN = os.environ["HUBSPOT_TOKEN"]


def fetch_all_deals(api_client: HubSpot) -> list[dict[str, Any]]:
    all_deals: list[dict[str, Any]] = []
    after: str | None = None

    while True:
        try:
            response = api_client.crm.deals.basic_api.get_page(
                limit=100,
                after=after,
                properties=[
                    "name",
                    "job_number",
                    "moved_to_runn_",
                    "amount",
                    "pipeline",
                    "dealname",
                    "dealstage",
                    "dealtype",
                    "work_start_date",
                    "project_duration",
                    "confidence_weighting",
                    "work_type_2",
                    "work_type_3__dx_new_",
                    "closedate",
                    "createdate",
                ],
                associations=["company"],
            )
            all_deals.extend([deal.to_dict() for deal in response.results])

            after = response.paging.next.after if response.paging and response.paging.next else None
            if not after:
                break
        except ApiException as error:  # pragma: no cover
            print(f"Exception when requesting deals: {error}")
            break

    return all_deals


def _extract_company_association(value: Iterable[dict[str, Any]] | None) -> int | None:
    if not value:
        return None

    for association in value:
        if association.get("type") == "deal_to_company":
            try:
                return int(association["id"])
            except (TypeError, ValueError, KeyError):
                return None
    return None


def process_dataframe(df: pd.DataFrame) -> pd.DataFrame:
    df["associations_company"] = (
        df["associations"]
        .str.get("companies")
        .str.get("results")
        .apply(_extract_company_association)
        .astype("Int64")
    )

    df["id"] = df["id"].astype("Int64")
    df["archived"] = df["archived"].astype(bool)
    df["archived_at"] = df["archived_at"].apply(pd.Timestamp)

    properties = df["properties"]

    df["properties_amount"] = pd.to_numeric(properties.str.get("amount"), errors="coerce")
    df["properties_closedate"] = properties.str.get("closedate").apply(pd.Timestamp)
    df["properties_confidence_weighting"] = pd.to_numeric(
        properties.str.get("confidence_weighting"), errors="coerce"
    )
    df["properties_createdate"] = properties.str.get("createdate").apply(pd.Timestamp)
    df["properties_dealname"] = properties.str.get("dealname").astype(str)
    df["properties_dealstage"] = properties.str.get("dealstage").astype(str)
    df["properties_dealtype"] = properties.str.get("dealtype").astype(str)
    df["properties_job_number"] = properties.str.get("job_number").astype(str)
    df["properties_moved_to_runn_"] = properties.str.get("moved_to_runn_").astype(str)
    df["properties_pipeline"] = properties.str.get("pipeline").astype(str)
    df["properties_project_duration"] = pd.to_numeric(
        properties.str.get("project_duration"), errors="coerce"
    )
    df["properties_work_start_date"] = properties.str.get("work_start_date").apply(pd.Timestamp)
    df["properties_work_type_2"] = properties.str.get("work_type_2").astype(str)
    df["properties_work_type_3__dx_new_"] = properties.str.get("work_type_3__dx_new_").astype(str)

    df["created_at"] = df["created_at"].apply(pd.Timestamp)
    df["updated_at"] = df["updated_at"].apply(pd.Timestamp)
    df["import_date"] = pd.Timestamp(datetime.now(timezone.utc))

    ordered_df = cast(
        pd.DataFrame,
        df[
            [
                "id",
                "archived",
                "archived_at",
                "properties_amount",
                "properties_closedate",
                "properties_confidence_weighting",
                "properties_createdate",
                "properties_dealname",
                "properties_dealstage",
                "properties_dealtype",
                "properties_job_number",
                "properties_moved_to_runn_",
                "properties_pipeline",
                "properties_project_duration",
                "properties_work_start_date",
                "properties_work_type_2",
                "properties_work_type_3__dx_new_",
                "associations_company",
                "created_at",
                "updated_at",
                "import_date",
            ]
        ].copy(),
    )

    return ordered_df


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


def main(data: dict[str, Any] | None = None, context: object | None = None) -> None:
    del data, context

    api_client = HubSpot(access_token=HUBSPOT_TOKEN)

    ingest_time = datetime.now(timezone.utc)
    config = load_config(PROJECT_ID, SERVICE_NAME, ingest_time)

    try:
        deals = fetch_all_deals(api_client)
        df = pd.DataFrame(deals)
        processed_df = process_dataframe(df)
        write_to_bigquery(config, processed_df, "WRITE_TRUNCATE_DATA")
    except ApiException as error:  # pragma: no cover
        print(f"Exception when calling deals API: {error}")


if __name__ == "__main__":  # pragma: no cover
    main({}, None)
