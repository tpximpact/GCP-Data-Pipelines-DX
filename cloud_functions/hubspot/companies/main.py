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


def fetch_all_companies(api_client):
    all_deals = []
    after = None
    while True:
        try:
            # Fetch a page of deals
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
            os.environ.get("TABLE_NAME") or "hubspot_companies", ingest_time
        ),
        "location": os.environ.get("TABLE_LOCATION") or "europe-west2",
        "service": service,
    }


def main(data: dict, context: dict = None):
    service = "Data Pipeline - HubSpot companies"
    hubspot_token = access_secret_version(project_id, "HUBSPOT_TOKEN")

    api_client = HubSpot(access_token=hubspot_token)

    now = datetime.now(timezone.utc)
    config = load_config(project_id, service, now)

    try:
        deals = fetch_all_companies(api_client)
        df = pd.DataFrame(deals)

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
        df["import_date"] = pd.Timestamp(now)

        df = df[
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

        write_to_bigquery(config, df, "WRITE_TRUNCATE_DATA")

    except ApiException as e:
        print("Exception when calling basic_api->get_page: %s\n" % e)


if __name__ == "__main__":
    main({})
