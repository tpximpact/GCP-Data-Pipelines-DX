import asyncio
import os
import pandas as pd

from datetime import datetime, timezone
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
    "url"        : "https://api.harvestapp.com/v2/time_entries?page=",
    "headers"    : harvest_headers(project_id, service),
    "dataset_id" : os.environ.get("DATASET_ID") if os.environ.get("DATASET_ID") else "Harvest_Raw",
    "gcp_project": project_id,
    "table_name" : os.environ.get("TABLE_NAME") if os.environ.get("TABLE_NAME") else "timesheets",
    "location"   : os.environ.get("TABLE_LOCATION") if os.environ.get("TABLE_LOCATION") else "europe-west2",
    "service"    : service,
  }

def main(data: dict, context):
  service = "Data Pipeline - Harvest Timesheets"
  config  = load_config(project_id, service)

  pages, entries = get_harvest_pages(config["url"], config["headers"])
  print(f"Total pages: {pages}")



  df = asyncio.run(
    get_all_data(
      config["url"], config["headers"], pages, "time_entries", batch_size=10
    )
  ).reset_index(drop=True)

  df = find_and_flatten_columns(df)

  df["unique_id"]   = df["id"].astype(str) + "-" + df["updated_at"].astype(str)
  df["import_date"] = datetime.now(timezone.utc).strftime('%Y-%m-%dT%H:%M:%SZ')

#   df["spent_date"]  = df["spent_date"].apply(lambda dateString: pd.Timestamp(f"{dateString}T00:00:00Z"))
#   df["created_at"]  = df["created_at"].apply(lambda dateString: pd.Timestamp(dateString))
#   df["updated_at"]  = df["updated_at"].apply(lambda dateString: pd.Timestamp(dateString))
#   df["import_date"] = df["import_date"].apply(lambda dateString: pd.Timestamp(dateString))


  df["invoice_id"]     = df["invoice"].apply(lambda invoice: f"{invoice["id"]}" if invoice else "")
  df["invoice_number"] = df["invoice"].apply(lambda invoice: f"{invoice["number"]}" if invoice else "")

  assert abs(len(df) == entries) < 30
  columns_to_drop = ["invoice", "started_time", "ended_time", "timer_started_at"]
  df = df.drop(columns=columns_to_drop, errors="ignore")

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
