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
                    "job_number",
                    "moved_to_runn_",
                    "amount",
                    "pipeline",
                    "dealname",
                    "dealstage",
                    "work_start_date",
                    "project_duration",
                    "confidence_weighting",
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


def main(data: dict, context: dict = None):
    service = "Data Pipeline - HubSpot deals"
    hubspot_token = access_secret_version(project_id, "HUBSPOT_TOKEN")

    api_client = HubSpot(access_token=hubspot_token)
    now = datetime.now(timezone.utc)
    config = load_config(project_id, service, now)
    import_date = now.strftime("%Y-%m-%dT%H:%M:%SZ")

    try:
        deals = fetch_all_deals(api_client)
        df = pd.DataFrame(deals)

        df["unique_id"] = df["id"].astype(str) + "-" + df["updated_at"].astype(str)
        df["import_date"] = import_date
        # Pull out associated company id
        df["associations_company"] = (
            df["associations"]
            .str.get("companies")
            .str.get("results")
            .apply(
                # id of first item in nested list where type is 'deal_to_company'
                lambda items: (
                    next(
                        item["id"]
                        for item in items
                        if item["type"] == "deal_to_company"
                    )
                    if items
                    else None
                )
            )
        )
        # Associations data very loosely structured. Can't ingest it.
        df["associations"] = None
        df = find_and_flatten_columns(df)

        write_to_bigquery(config, df, "WRITE_TRUNCATE")

    except ApiException as e:
        print("Exception when calling basic_api->get_page: %s\n" % e)


if __name__ == "__main__":
    main({})
