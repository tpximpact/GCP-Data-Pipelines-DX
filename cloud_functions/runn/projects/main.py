import os
import pandas as pd
import requests

from data_pipeline_tools.auth import runn_headers
from data_pipeline_tools.util import write_to_bigquery


project_id = os.environ.get("GOOGLE_CLOUD_PROJECT")
project_id="tpx-dx-dashboards"
service = "Data Pipeline - Runn Projects"

if not project_id:
    project_id = input("Enter GCP project ID: ")

def load_config(project_id, service, nextCursor) -> dict:
    return {
        "url": "https://api.runn.io/projects/?includeArchived=false&&cursor="+nextCursor,
        "headers": runn_headers(project_id, service),
        "dataset_id": "Runn_Raw",  #os.environ.get("DATASET_ID"), // terraform/environments/infra/bigquery_datasets.tf
        "gcp_project": project_id,
        "table_name": "projects", #os.environ.get("TABLE_NAME"), // table_id terraform/environments/infra/bigquery_tables_runn.tf
        "location": "europe-west2", #os.environ.get("TABLE_LOCATION"), // terraform/environments/infra/bigquery_datasets.tf
        "service": service,
    }

def main(data: dict, context):
    projects=[]
    nextCursor=""
    config = load_config(project_id, service, nextCursor)

    while True:
        config = load_config(project_id, service, nextCursor)
        response = requests.get(url=config["url"], headers=config["headers"])
    
        if response.status_code == 200:
            data = response.json()
            # how many requests the client can make
            rate_limit = response.headers.get("x-ratelimit-limit")
            # how many requests remain to the client in the time window
            rate_limit_remaining = response.headers.get("x-ratelimit-remaining")
            # how many seconds must pass before the rate limit resets
            rate_limit_reset = response.headers.get("x-ratelimit-reset")
            retry_after = response.headers.get("retry-after")
            print(f"Rate Limit can make: {rate_limit}")
            print(f"Rate Limit remaining: {rate_limit_remaining}")
            print(f"Rate Limit time to reset: {rate_limit_reset}")
            print(f"Retry after: {retry_after}")
           
            projects.extend(data.get("values", []))
            nextCursor = data.get("nextCursor")
            if not nextCursor:
                break
        else:
            raise Exception(f"Failed to fetch people: {response.status_code}, {response.text}")

    print(f"Total number of projects fetched: {len(projects)}")


    projects_df = pd.DataFrame(projects)
    write_to_bigquery(config, projects_df, "WRITE_TRUNCATE")
    print("Done")


if __name__ == "__main__":
    main({}, None)
