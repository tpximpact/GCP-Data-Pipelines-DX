import os
import pandas as pd
import requests

from data_pipeline_tools.auth import runn_headers
from data_pipeline_tools.util import (
   handle_runn_rate_limits,
   write_to_bigquery
)

project_id = os.environ.get("GOOGLE_CLOUD_PROJECT")

if not project_id:
    project_id = "tpx-dx-dashboards"

if not project_id:
    project_id = input("Enter GCP project ID: ")

def load_config(project_id, service) -> dict:
    return {
        "url": "https://api.runn.io/teams",
        "headers": runn_headers(project_id, service),
        "dataset_id": os.environ.get("DATASET_ID"),
        "gcp_project": project_id,
        "table_name": os.environ.get("TABLE_NAME"),
        "location": os.environ.get("TABLE_LOCATION"),
        "service": service,
    }

def main(data: dict, context):
    service = "Data Pipeline - Runn teams"
    config = load_config(project_id, service)
    teams = []
    next_cursor = ""

    while True:
        url = config["url"] + "?cursor=" + next_cursor if next_cursor else config["url"]
        response = requests.get(url=url, headers=config["headers"])
    
        if response.status_code == 200:
            data = response.json()
            teams.extend(data.get("values", []))
            next_cursor = data.get("nextCursor")

            if not next_cursor:
                break
        else:
            raise Exception(f"Failed to fetch teams: {response.status_code}, {response.text}")
    
    
    print(f"Total number of teams fetched: {len(teams)}")

    teams_df = pd.DataFrame(teams)
    write_to_bigquery(config, teams_df, "WRITE_TRUNCATE")
    handle_runn_rate_limits(response)
    print("Done")


if __name__ == "__main__":
    main({}, None)
