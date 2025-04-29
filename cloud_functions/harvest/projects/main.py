import asyncio
import os
import pandas as pd

from datetime import datetime
from dateutil.relativedelta import relativedelta

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
    "url"        : "https://api.harvestapp.com/v2/projects?page=",
    "headers"    : harvest_headers(project_id, service),
    "dataset_id" : os.environ.get("DATASET_ID") if os.environ.get("DATASET_ID") else "Harvest_Raw",
    "gcp_project": project_id,
    "table_name" : os.environ.get("TABLE_NAME") if os.environ.get("TABLE_NAME") else "projects",
    "location"   : os.environ.get("TABLE_LOCATION") if os.environ.get("TABLE_LOCATION") else "europe-west2",
    "service"    : service,
  }

def main(data: dict, context):
  service = "Data Pipeline - Harvest Projects"
  config  = load_config(project_id, service)

  pages, entries = get_harvest_pages(config["url"], config["headers"])
  print(f"Total pages: {pages}")

  df = asyncio.run(
    get_all_data(config["url"], config["headers"], pages, "projects", batch_size=10)
  )

  print(df)

  df = find_and_flatten_columns(df)
  df["starts_on"] = df["starts_on"].apply(lambda dateString: pd.Timestamp(dateString))
  df["ends_on"]   = df["ends_on"].apply(lambda dateString: pd.Timestamp(dateString))

  df["created_at"] = df["created_at"].apply(lambda dateString: pd.Timestamp(dateString))
  df["updated_at"] = df["updated_at"].apply(lambda dateString: pd.Timestamp(dateString))

  assert len(df) == entries
  columns_to_drop = []
  df = df.drop(columns=columns_to_drop, errors="ignore")

  df = df[[
    'id',
    'name',
    'code',
    'starts_on',
    'ends_on',
    'cost_budget',
    'cost_budget_include_expenses',
    'hourly_rate',
    'fee',
    'client_id',
    'client_name',
    'client_currency',
    'is_active',
    'is_billable',
    'is_fixed_fee',
    'bill_by',
    'budget',
    'budget_by',
    'budget_is_monthly',
    'notify_when_over_budget',
    'over_budget_notification_percentage',
    'show_budget_to_all',
    'over_budget_notification_date',
    'notes',
    'created_at',
    'updated_at'
  ]]

  bigquery_client = bigquery_client_get(location=config["location"])

#   write_to_bigquery(
#     client=bigquery_client,
#     dataset_id=config["dataset_id"],
#     table_name=config["table_name"],
#     df=df,
#     write_disposition="WRITE_TRUNCATE"
#   )

if __name__ == "__main__":
    main({}, None)
