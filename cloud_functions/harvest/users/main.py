import asyncio
import os
import pandas as pd

from data_pipeline_tools.asyncs import get_all_data
from data_pipeline_tools.auth import harvest_headers
from data_pipeline_tools.util import (
    find_and_flatten_columns,
    get_harvest_pages
)

from data_pipeline_tools.bigquery_helpers import (
  bigquery_client_get,
  write_to_bigquery
)

project_id = os.environ.get("GOOGLE_CLOUD_PROJECT")

if not project_id:
  project_id = "tpx-dx-dashboards"

def load_config(project_id, service) -> dict:
  return {
    "url"        : "https://api.harvestapp.com/v2/users?page=",
    "headers"    : harvest_headers(project_id, service),
    "dataset_id" : os.environ.get("DATASET_ID") if os.environ.get("DATASET_ID") else "Harvest_Raw",
    "gcp_project": project_id,
    "table_name" : os.environ.get("TABLE_NAME") if os.environ.get("TABLE_NAME") else "users",
    "location"   : os.environ.get("TABLE_LOCATION") if os.environ.get("TABLE_LOCATION") else "europe-west2",
    "service"    : service
  }

def main(data: dict, context):
    service = "Data Pipeline - Harvest Users"
    config  = load_config(project_id, service)

    pages, entries = get_harvest_pages(config["url"], config["headers"])
    print(f"Total pages: {pages}")

    df = asyncio.run(
        get_all_data(config["url"], config["headers"], pages, "users", batch_size=10)
    ).reset_index(drop=True)

    df["created_at"] = df["created_at"].apply(lambda dateString: pd.Timestamp(dateString))
    df["updated_at"] = df["updated_at"].apply(lambda dateString: pd.Timestamp(dateString))

    df = find_and_flatten_columns(df)

    assert len(df) == entries

    columns_to_drop = []
    df = df.drop(columns=columns_to_drop, errors="ignore")

    df = df [[
      'id',
      'first_name',
      'last_name',
      'email',
      'telephone',
      'timezone',
      'weekly_capacity',
      'has_access_to_all_future_projects',
      'is_contractor',
      'is_active',
      'calendar_integration_enabled',
      'calendar_integration_source',
      'can_create_projects',
      'default_hourly_rate',
      'cost_rate',
      'roles',
      'access_roles',
      'permissions_claims',
      'avatar_url',
      'created_at',
      'updated_at'
    ]]

    bigquery_client = bigquery_client_get(location=config["location"])

    write_to_bigquery(
      client=bigquery_client,
      dataset_id=config["dataset_id"],
      table_name=config["table_name"],
      df=df,
      write_disposition="WRITE_TRUNCATE"
    )

if __name__ == "__main__":
    main({}, None)
