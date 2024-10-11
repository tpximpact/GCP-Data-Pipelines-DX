import os
import pandas as pd
import requests

from data_pipeline_tools.auth import runn_headers
from data_pipeline_tools.bigquery_helpers import (
  bigquery_client_get,
  write_to_bigquery
)

from data_pipeline_tools.runn_tools import (
  reference_value_get
)

project_id = os.environ.get("GOOGLE_CLOUD_PROJECT")

if not project_id:
  project_id = "tpx-dx-dashboards"


def load_config(project_id, service) -> dict:
  return {
    "url": "https://api.runn.io/clients",
    "headers": runn_headers(project_id, service),
    "dataset_id": os.environ.get("DATASET_ID")  if os.environ.get("DATASET_ID") else "Runn_Raw",
    "gcp_project": project_id,
    "table_name": os.environ.get("TABLE_NAME")  if os.environ.get("TABLE_NAME") else "clients",
    "location": os.environ.get("TABLE_LOCATION") if os.environ.get("TABLE_LOCATION") else "europe-west2",
    "service": service,
  }

def page_get(url, headers):
  print("getting page", url)

  response = requests.get(url=url, headers=headers)

  if response.status_code == 200:
    data = response.json()
    next_cursor = data.get("nextCursor")

    df = pd.DataFrame(data.get("values", []))

    if df.empty:
        return df, ""

    df["harvestId"] = df["references"].apply(lambda references: reference_value_get("Harvest", references))
    df["createdAt"] = df["createdAt"].apply(lambda dateString: pd.Timestamp(dateString))
    df["updatedAt"] = df["updatedAt"].apply(lambda dateString: pd.Timestamp(dateString))

    df = df.drop(columns=["references"])

    return df, next_cursor

  else:
      raise Exception(f"Failed to fetch clients: {response.status_code}, {response.text}")


def main(data: dict, context):
  service = "Data Pipeline - Runn clients"
  config = load_config(project_id, service)

  bigquery_client = bigquery_client_get(location=config["location"])

  next_cursor = ""
  has_more = True
  df = pd.DataFrame([])

  while has_more:
    url = config["url"] + "?cursor=" + next_cursor if next_cursor else config["url"]

    page_df, next_cursor = page_get(url, headers=config["headers"])
    df = pd.concat([df, page_df])

    if not next_cursor:
      has_more = False
      break

  write_to_bigquery(
    client=bigquery_client,
    dataset_id=config["dataset_id"],
    table_name=config["table_name"],
    df=df,
    write_disposition="WRITE_TRUNCATE"
  )

if __name__ == "__main__":
    main({}, None)
