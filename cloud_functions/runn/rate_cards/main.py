import os
import pandas as pd
import requests

from data_pipeline_tools.auth import runn_headers

from data_pipeline_tools.bigquery_helpers import (
  bigquery_client_get,
  write_to_bigquery
)


project_id = os.environ.get("GOOGLE_CLOUD_PROJECT")

if not project_id:
    project_id = "tpx-dx-dashboards"

def load_config(project_id, service) -> dict:
  return {
    "url"                : "https://api.runn.io/rate-cards",
    "headers"            : runn_headers(project_id, service),
    "dataset_id"         : os.environ.get("DATASET_ID") if os.environ.get("DATASET_ID") else "Runn_Raw",
    "gcp_project"        : project_id,
    "rates_table_name"   : os.environ.get("RATES_TABLE_NAME") if os.environ.get("RATES_TABLE_NAME") else "rate_cards",
    "projects_table_name": os.environ.get("PROJECTS_TABLE_NAME") if os.environ.get("PROJECTS_TABLE_NAME") else "rate_project_rates",
    "location"           : os.environ.get("TABLE_LOCATION") if os.environ.get("TABLE_LOCATION") else "europe-west2",
    "service"            : service
  }

def process_results_page(results, df_rates, df_projects):
  projects = []

  df = pd.DataFrame(results)

  for index, row in df.iterrows():
    if row["projectIds"]:
      for project in row["projectIds"]:
        projects.append({
          "projectId": project,
          "rateCard": row["id"]
        })

  df_rates    = pd.concat([df_rates, df])
  df_projects = pd.concat([df_projects, pd.DataFrame(projects)])

  return df_rates, df_projects


def main(data: dict, context):
  service     = "Data Pipeline - Runn rate cards"
  config      = load_config(project_id, service)
  roles       = []
  next_cursor = ""

  df_rates    = pd.DataFrame([])
  df_projects = pd.DataFrame([])


  while True:
    url = config["url"] + "?cursor=" + next_cursor if next_cursor else config["url"]
    print("getting page", url)

    response = requests.get(url=url, headers=config["headers"])

    if response.status_code == 200:
      data = response.json()
      df_rates, df_projects = process_results_page(data.get("values", []), df_rates, df_projects)
      next_cursor = data.get("nextCursor")

      if not next_cursor:
        break
    else:
      raise Exception(f"Failed to fetch roles: {response.status_code}, {response.text}")

  df_rates["createdAt"] = df_rates["createdAt"].apply(lambda dateString: pd.Timestamp(dateString))
  df_rates["updatedAt"] = df_rates["updatedAt"].apply(lambda dateString: pd.Timestamp(dateString))
  df_rates = df_rates.drop(columns=["projectIds"])

  bigquery_client = bigquery_client_get(location=config["location"])

  write_to_bigquery(
    client=bigquery_client,
    dataset_id=config["dataset_id"],
    table_name=config["rates_table_name"],
    df=df_rates,
    write_disposition="WRITE_TRUNCATE"
  )

  write_to_bigquery(
    client=bigquery_client,
    dataset_id=config["dataset_id"],
    table_name=config["projects_table_name"],
    df=df_projects,
    write_disposition="WRITE_TRUNCATE"
  )

  print("Done")


if __name__ == "__main__":
    main({}, None)
