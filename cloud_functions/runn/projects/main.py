import os
import pandas as pd
import requests

from data_pipeline_tools.auth import runn_headers
from data_pipeline_tools.util import (
    find_and_flatten_columns,
    handle_runn_rate_limits,
    write_to_bigquery
)

project_id = os.environ.get("GOOGLE_CLOUD_PROJECT")

if not project_id:
    project_id = "tpx-dx-dashboards"

def load_config(project_id, service) -> dict:
    return {
        "url": "https://api.runn.io/projects",
        "headers": runn_headers(project_id, service),
        "dataset_id": os.environ.get("DATASET_ID"),
        "gcp_project": project_id,
        "table_name": os.environ.get("TABLE_NAME"),
        "location": os.environ.get("TABLE_LOCATION"),
        "service": service,
    }


def get_harvest_id(references):
    if references:
        if references[0]["referenceName"] == "Harvest":
            return str(references[0]["externalId"])

    return ""

def get_first_project_tag(tags):
    if tags:
        if tags[0]["name"] in ['Project', 'Retainer']:
            return str(tags[0]["name"])

    return "No tag"

def main(data: dict, context):
    service = "Data Pipeline - Runn Projects"
    config = load_config(project_id, service)
    projects = []
    next_cursor = ""

    while True:
        url = config["url"] + "?cursor=" + next_cursor if next_cursor else config["url"]
        response = requests.get(url=url, headers=config["headers"])

        if response.status_code == 200:
            data = response.json()
            projects.extend(data.get("values", []))
            next_cursor = data.get("nextCursor")

            if not next_cursor:
                break
        else:
            raise Exception(f"Failed to fetch people: {response.status_code}, {response.text}")

        projects_df = pd.DataFrame(projects)
        harvest_ids = projects_df["references"].apply(get_harvest_id)
        project_type = projects_df["tags"].apply(get_first_project_tag)

        projects_df["harvest_id"] = harvest_ids
        projects_df["project_type"] = project_type
        projects_df = projects_df.drop(columns=["references", "customFields", "tags"])

        write_to_bigquery(config, projects_df, "WRITE_TRUNCATE")
        handle_runn_rate_limits(response)

        print(f"Total number of projects fetched: {len(projects)}")

if __name__ == "__main__":
    main({}, None)
