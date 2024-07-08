import os
import pandas as pd
import requests
import datetime
import time
from data_pipeline_tools.auth import runn_headers
from data_pipeline_tools.util import write_to_bigquery
from copy import deepcopy

project_id = os.environ.get("GOOGLE_CLOUD_PROJECT")
project_id="tpx-dx-dashboards"
service = "Data Pipeline - Assignments"
if not project_id:
    project_id = input("Enter GCP project ID: ")

def load_config(project_id, service, nextCursor) -> dict:
    return {
        "url": "https://api.runn.io/assignments/?startDate=2024-04-01&limit=500&cursor="+nextCursor,
        "headers": runn_headers(project_id, service),
        "dataset_id": "Runn_Raw",  #os.environ.get("DATASET_ID"),
        "gcp_project": project_id,
        "table_name": "assignments", #os.environ.get("TABLE_NAME"),
        "location": "europe-west2", #os.environ.get("TABLE_LOCATION"),
        "service": service,
    }

def load_processed_config(project_id) -> dict:
    return {
        "dataset_id": "Runn_Processed",  #os.environ.get("DATASET_ID"),
        "gcp_project": project_id,
        "table_name": "processed_assignments", #os.environ.get("TABLE_NAME"),
        "location": "europe-west2", #os.environ.get("TABLE_LOCATION"),
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

def expand_dates(row):
    # Convert startDate and endDate to datetime objects
    start_date = datetime.datetime.strptime(row["startDate"], "%Y-%m-%d")
    end_date = datetime.datetime.strptime(row["endDate"], "%Y-%m-%d")
    
    # Check if startDate is equal to endDate
    if start_date == end_date:
        return [row]
    
    # Generate date range
    date_range = pd.date_range(start=start_date, end=end_date, freq='D')
    
    
    # Create expanded rows
    expanded_rows = []
    for single_date in date_range:
        new_row = deepcopy(row)  # Copy all fields from the original row
        new_row['startDate'] = single_date.strftime("%Y-%m-%d")  # Update startDate
        new_row["endDate"] = single_date.strftime("%Y-%m-%d")  # Update endDate
        expanded_rows.append(new_row)
 
    return expanded_rows

def main(data: dict, context):
    assignments=[]
    nextCursor=""
    config = load_config(project_id, service, nextCursor)
    processed_config = load_processed_config(project_id)
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

    # write to runn processed assignments table
    print("Starting process assignments date range...")
    extended_assignments=[]
    for row in assignments:
        extended_assignments.extend(expand_dates(row))
    
    print(f"Total number of assignments after process: {len(assignments)}")
    processed_assignments_df = pd.DataFrame(extended_assignments)
    write_to_bigquery(processed_config, processed_assignments_df, "WRITE_TRUNCATE")

    print("Done")


if __name__ == "__main__":
    main({}, None)
