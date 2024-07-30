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

def load_config(project_id, service) -> dict:
    return {
        "url": "https://api.runn.io/rate-cards",
        "headers": runn_headers(project_id, service),
        "dataset_id": os.environ.get("DATASET_ID"),
        "gcp_project": project_id,
        "table_name": os.environ.get("TABLE_NAME"),
        "projects_table_name": os.environ.get("PROJECTS_TABLE_NAME"),
        "location": os.environ.get("TABLE_LOCATION"),
        "service": service,
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


    df = df.drop(columns=["projectIds"])
    df_rates = pd.concat([df_rates, df])
    df_projects = pd.concat([df_projects, pd.DataFrame(projects)])

    return df_rates, df_projects


def main(data: dict, context):
    service = "Data Pipeline - Runn rate cards"
    config = load_config(project_id, service)
    roles = []
    next_cursor = ""

    df_rates = pd.DataFrame([])
    df_projects = pd.DataFrame([])


    while True:
        url = config["url"] + "?cursor=" + next_cursor if next_cursor else config["url"]
        response = requests.get(url=url, headers=config["headers"])

        if response.status_code == 200:
            data = response.json()
            df_rates, df_projects = process_results_page(data.get("values", []), df_rates, df_projects)
            next_cursor = data.get("nextCursor")

            if not next_cursor:
                break
        else:
            raise Exception(f"Failed to fetch roles: {response.status_code}, {response.text}")



    write_to_bigquery(config, df_rates, "WRITE_TRUNCATE")
    config["table_name"] = config["projects_table_name"]
    write_to_bigquery(config, df_projects, "WRITE_TRUNCATE")

    handle_runn_rate_limits(response)
    print("Done")


if __name__ == "__main__":
    main({}, None)
