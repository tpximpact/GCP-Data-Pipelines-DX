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
    "url"        : "https://api.runn.io/projects",
    "headers"    : runn_headers(project_id, service),
    "dataset_id" : os.environ.get("DATASET_ID") if os.environ.get("DATASET_ID") else "Runn_Raw",
    "gcp_project": project_id,
    "table_name" : os.environ.get("TABLE_NAME") if os.environ.get("TABLE_NAME") else "projects",
    "location"   : os.environ.get("TABLE_LOCATION") if os.environ.get("TABLE_LOCATION") else "europe-west2",
    "service"    : service,
  }


def get_first_project_tag(tags):
  if tags:
    if tags[0]["name"] in ['Project', 'Retainer']:
      return str(tags[0]["name"])

  return "No tag"

def main(data: dict, context):
  service     = "Data Pipeline - Runn Projects"
  config      = load_config(project_id, service)
  projects    = []
  next_cursor = ""

  while True:
    url = config["url"] + "?cursor=" + next_cursor if next_cursor else config["url"]
    print("getting page", url)

    response = requests.get(url=url, headers=config["headers"])

    if response.status_code == 200:
      data = response.json()
      projects.extend(data.get("values", []))
      next_cursor = data.get("nextCursor")

      if not next_cursor:
        break
    else:
        raise Exception(f"Failed to fetch people: {response.status_code}, {response.text}")

  df = pd.DataFrame(projects)
  df["harvestId"]   = df["references"].apply(lambda references: reference_value_get("Harvest", references))
  df["projectType"] = df["tags"].apply(get_first_project_tag)
  df = df.drop(columns=["references", "customFields", "tags"])

  bigquery_client = bigquery_client_get(location=config["location"])

  write_to_bigquery(
    client=bigquery_client,
    dataset_id=config["dataset_id"],
    table_name=config["table_name"],
    df=df,
    write_disposition="WRITE_TRUNCATE"
  )

  print(f"Total number of projects fetched: {len(projects)}")

if __name__ == "__main__":
    main({}, None)
