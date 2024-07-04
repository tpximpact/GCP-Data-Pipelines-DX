import os
import pandas as pd
import requests
import time
from data_pipeline_tools.auth import runn_headers
from data_pipeline_tools.util import write_to_bigquery

project_id = os.environ.get("GOOGLE_CLOUD_PROJECT")
project_id="tpx-dx-dashboards"
service = "Data Pipeline - Assignments"
if not project_id:
    project_id = input("Enter GCP project ID: ")

def load_config(project_id, service, nextCursor) -> dict:
    return {
        "url": "https://api.runn.io/assignments/?minDate=2024-04-01&cursor="+nextCursor,
        "headers": runn_headers(project_id, service),
        "dataset_id": "Runn_Raw",  #os.environ.get("DATASET_ID"),
        "gcp_project": project_id,
        "table_name": "assignments", #os.environ.get("TABLE_NAME"),
        "location": "europe-west2", #os.environ.get("TABLE_LOCATION"),
        "service": service,
    }

def handle_rate_limits(response):
    rate_limit_remaining = int(response.headers.get("x-ratelimit-remaining", 1))
    rate_limit_reset = int(response.headers.get("x-ratelimit-reset", 0))
    retry_after = int(response.headers.get("retry-after", 0))

    print(f"Rate Limit remaining: {rate_limit_remaining}")
    print(f"Rate Limit time to reset: {rate_limit_reset}")
    print(f"Retry after: {retry_after}")

    if rate_limit_remaining == 0:
        wait_time = max(rate_limit_reset, retry_after)
        print(f"Rate limit reached. Waiting for {wait_time} seconds.")
        time.sleep(wait_time)

def main(data: dict, context):
    assignments=[]
    nextCursor=""
    config = load_config(project_id, service, nextCursor)

    while True:
        config = load_config(project_id, service, nextCursor)
        response = requests.get(url=config["url"], headers=config["headers"])
    
        if response.status_code == 200:
            data = response.json()
            handle_rate_limits(response)
            assignments.extend(data.get("values", []))
            nextCursor = data.get("nextCursor")

            if not nextCursor:
                break
        else:
            raise Exception(f"Failed to fetch assignments: {response.status_code}, {response.text}")
    
    
    print(f"Total number of assignments fetched: {len(assignments)}")

    assignments_df = pd.DataFrame(assignments)
    write_to_bigquery(config, assignments_df, "WRITE_TRUNCATE")
    print("Done")


if __name__ == "__main__":
    main({}, None)
