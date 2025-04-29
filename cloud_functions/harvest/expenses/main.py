import asyncio
import pandas as pd
import os

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
    "url"        : "https://api.harvestapp.com/v2/expenses?page=",
    "headers"    : harvest_headers(project_id, service),
    "dataset_id" : os.environ.get("DATASET_ID") if os.environ.get("DATASET_ID") else "Harvest_Raw",
    "gcp_project": project_id,
    "table_name" : os.environ.get("TABLE_NAME") if os.environ.get("TABLE_NAME") else "expenses",
    "location"   : os.environ.get("TABLE_LOCATION") if os.environ.get("TABLE_LOCATION") else "europe-west2",
    "service"    : service,
  }

def main(data: dict, context):
  service = "Data Pipeline - Harvest Expenses"
  config  = load_config(project_id, service)

  pages, entries = get_harvest_pages(config["url"], config["headers"])

  print(f"Total pages: {pages}")

  df = asyncio.run(
      get_all_data(config["url"], config["headers"], pages, "expenses", batch_size=10)
  ).reset_index(drop=True)

  df = find_and_flatten_columns(df)

  df["created_at"]                 = df["created_at"].apply(lambda dateString: pd.Timestamp(dateString))
  df["updated_at"]                 = df["updated_at"].apply(lambda dateString: pd.Timestamp(dateString))
  df["spent_date"]                 = df["spent_date"].apply(lambda dateString: pd.Timestamp(f"{dateString}T00:00:00Z"))
  df["user_assignment_created_at"] = df["user_assignment_created_at"].apply(lambda dateString: pd.Timestamp(dateString))
  df["user_assignment_updated_at"] = df["user_assignment_updated_at"].apply(lambda dateString: pd.Timestamp(dateString))

  df["invoice_id"]     = df["invoice"].apply(lambda invoice: f"{invoice["id"]}" if invoice else "")
  df["invoice_number"] = df["invoice"].apply(lambda invoice: f"{invoice["number"]}" if invoice else "")

  df["expense_category_unit_price"] = df["expense_category_unit_price"].astype(float)
  df["expense_category_unit_name"]  = df["expense_category_unit_name"].astype(str)

  assert len(df) == entries
  columns_to_drop = ["invoice"]
  df = df.drop(columns=columns_to_drop, errors="ignore")

  df = df[[
    'id',
    'invoice_id',
    'invoice_number',
    'spent_date',
    'total_cost',
    'user_id',
    'user_name',
    'client_id',
    'client_name',
    'client_currency',
    'project_id',
    'project_name',
    'project_code',
    'expense_category_id',
    'expense_category_name',
    'expense_category_unit_price',
    'expense_category_unit_name',
    'user_assignment_id',
    'user_assignment_is_project_manager',
    'user_assignment_is_active',
    'user_assignment_use_default_rates',
    'user_assignment_budget',
    'user_assignment_created_at',
    'user_assignment_updated_at',
    'user_assignment_hourly_rate',
    'units',
    'notes',
    'billable',
    'is_closed',
    'is_locked',
    'is_billed',
    'locked_reason',
    'receipt_url',
    'receipt_file_name',
    'receipt_file_size',
    'receipt_content_type',
    'created_at',
    'updated_at',
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
