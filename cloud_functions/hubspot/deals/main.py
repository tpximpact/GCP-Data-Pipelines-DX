import os
from hubspot import HubSpot
from hubspot.crm.deals import ApiException
import pandas as pd
from data_pipeline_tools.util import (
    write_to_bigquery,
    find_and_flatten_columns,
    target_daily_partition,
)
from data_pipeline_tools.auth import access_secret_version
from datetime import datetime, timezone

project_id = os.environ.get("GOOGLE_CLOUD_PROJECT")

if not project_id:
    project_id = "tpx-dx-dashboards"


def fetch_all_deals(api_client):
    all_deals = []
    after = None
    while True:
        try:
            # Fetch a page of deals
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
            all_deals.extend([x.to_dict() for x in response.results])

            # Check if there is a next page
            if response.paging and response.paging.next:
                after = (
                    response.paging.next.after
                )  # Get the 'after' cursor for the next page
            else:
                break  # No more pages, exit the loop

        except ApiException as e:
            print(f"Exception when requesting deals: {e}")
            break

    return all_deals


def load_config(project_id, service, ingest_time) -> dict:
    return {
        "dataset_id": os.environ.get("DATASET_ID") or "Hubspot_Raw",
        "gcp_project": project_id,
        "table_name": target_daily_partition(
            os.environ.get("TABLE_NAME") or "hubspot_deals", ingest_time
        ),
        "location": os.environ.get("TABLE_LOCATION") or "europe-west2",
        "service": service,
    }


def process_dataframe(df):
    # Pull out associated company id
    df["associations_company"] = (
        df["associations"]
        .str.get("companies")
        .str.get("results")
        .apply(
            # id of first item in nested list where type is 'deal_to_company'
            lambda items: (
                next(item["id"] for item in items if item["type"] == "deal_to_company")
                if items
                else None
            )
        )
        .astype("Int64")
    )
    # df = find_and_flatten_columns(df)
    df["id"] = df["id"].astype("Int64")
    df["properties_dealname"] = df["properties"].str.get("dealname").astype(str)
    df["archived"] = df["archived"].astype(bool)
    df["archived_at"] = df["archived_at"].apply(pd.Timestamp)
    df["properties_amount"] = pd.to_numeric(
        df["properties"].str.get("amount"), errors="coerce"
    )
    df["properties_closedate"] = (
        df["properties"].str.get("closedate").apply(pd.Timestamp)
    )
    df["properties_confidence_weighting"] = pd.to_numeric(
        df["properties"].str.get("confidence_weighting"), errors="coerce"
    )
    df["properties_createdate"] = (
        df["properties"].str.get("createdate").apply(pd.Timestamp)
    )
    df["properties_dealstage"] = df["properties"].str.get("dealstage").astype(str)
    df["properties_dealtype"] = df["properties"].str.get("dealtype").astype(str)
    df["properties_job_number"] = df["properties"].str.get("job_number").astype(str)
    df["properties_moved_to_runn_"] = (
        df["properties"].str.get("moved_to_runn_").astype(str)
    )
    df["properties_pipeline"] = pd.to_numeric(
        df["properties"].str.get("pipeline"), errors="coerce"
    ).astype("Int64")
    df["properties_project_duration"] = pd.to_numeric(
        df["properties"].str.get("project_duration"), errors="coerce"
    )
    df["properties_work_type_2"] = df["properties"].str.get("work_type_2").astype(str)
    df["properties_work_type_3__dx_new_"] = (
        df["properties"].str.get("work_type_3__dx_new_").astype(str)
    )
    df["created_at"] = df["created_at"].apply(pd.Timestamp)
    df["updated_at"] = df["updated_at"].apply(pd.Timestamp)
    df["properties_amount"] = pd.to_numeric(
        df["properties"].str.get("amount"), errors="coerce"
    )
    df["import_date"] = pd.Timestamp(datetime.now())

    df = df[
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
            "properties_work_type_2",
            "properties_work_type_3__dx_new_",
            "associations_company",
            "created_at",
            "updated_at",
            "import_date",
        ]
    ]

    return df


def main(data: dict, context: dict = None):
    service = "Data Pipeline - HubSpot deals"
    hubspot_token = access_secret_version(project_id, "HUBSPOT_TOKEN")

    api_client = HubSpot(access_token=hubspot_token)
    now = datetime.now(timezone.utc)
    config = load_config(project_id, service, now)

    try:
        deals = fetch_all_deals(api_client)
        df = pd.DataFrame(deals)
        df = process_dataframe(df)

        write_to_bigquery(config, df, "WRITE_TRUNCATE_DATA")

    except ApiException as e:
        print("Exception when calling basic_api->get_page: %s\n" % e)


if __name__ == "__main__":
    main({})
