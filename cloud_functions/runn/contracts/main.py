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
    "url"        : "https://api.runn.io/contracts?limit=200",
    "headers"    : runn_headers(project_id, service),
    "dataset_id" : os.environ.get("DATASET_ID") if os.environ.get("DATASET_ID") else "Runn_Raw",
    "gcp_project": project_id,
    "table_name" : os.environ.get("TABLE_NAME") if os.environ.get("TABLE_NAME") else "contracts",
    "location"   : os.environ.get("TABLE_LOCATION")  if os.environ.get("TABLE_LOCATION") else "europe-west2",
    "service"    : service,
  }

def main(data: dict, context):
  service = "Data Pipeline - Runn Contracts"
  config = load_config(project_id, service)
  people = []
  next_cursor = ""

  while True:
    url = config["url"] + "&cursor=" + next_cursor if next_cursor else config["url"]
    response = requests.get(url=url, headers=config["headers"])

    if response.status_code == 200:
      data = response.json()

      people.extend(data.get("values", []))
      next_cursor = data.get("nextCursor")

      if not next_cursor:
          break
    else:
        raise Exception(f"Failed to fetch people: {response.status_code}, {response.text}")


  df = pd.DataFrame(people)

  df["startDate"] = df["startDate"].apply(lambda dateString: pd.Timestamp(f"{dateString}T00:00:00Z"))
  df["endDate"]   = df["endDate"].apply(lambda dateString: pd.Timestamp(f"{dateString}T00:00:00Z") if dateString else None)
  df["createdAt"] = df["createdAt"].apply(lambda dateString: pd.Timestamp(dateString))
  df["updatedAt"] = df["updatedAt"].apply(lambda dateString: pd.Timestamp(dateString))

  df["day_monday"]    = df.rosteredDays.apply(lambda x: x["monday"])
  df["day_tuesday"]   = df.rosteredDays.apply(lambda x: x["tuesday"])
  df["day_wednesday"] = df.rosteredDays.apply(lambda x: x["wednesday"])
  df["day_thursday"]  = df.rosteredDays.apply(lambda x: x["thursday"])
  df["day_friday"]    = df.rosteredDays.apply(lambda x: x["friday"])


  df = df.drop(columns=["rosteredDays"])

  bigquery_client = bigquery_client_get(location=config["location"])

  write_to_bigquery(
    client=bigquery_client,
    dataset_id=config["dataset_id"],
    table_name=config["table_name"],
    df=df,
    write_disposition="WRITE_TRUNCATE"
  )

  print(f"Total number of contracts fetched: {len(df)}")


if __name__ == "__main__":
    main({}, None)
