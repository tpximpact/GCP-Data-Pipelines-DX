import os
import pandas as pd
import requests

from data_pipeline_tools.auth import runn_headers
from data_pipeline_tools.util import write_to_bigquery


project_id = os.environ.get("GOOGLE_CLOUD_PROJECT")
project_id="tpx-dx-dashboards"
service = "Data Pipeline - Runn People"
if not project_id:
    project_id = input("Enter GCP project ID: ")

def load_config(project_id, service, nextCursor) -> dict:
    return {
        "url": "https://api.runn.io/people/?cursor="+nextCursor,
        "headers": runn_headers(project_id, service),
        "dataset_id": "Runn_Raw",  #os.environ.get("DATASET_ID"),
        "gcp_project": project_id,
        "table_name": "people", #os.environ.get("TABLE_NAME"),
        "location": "europe-west2", #os.environ.get("TABLE_LOCATION"),
        "service": service,
    }

def get_harvest_id(references):
  if references:
    if references[0]["referenceName"] == "Harvest":
      return str(references[0]["externalId"])

  return ""

def main(data: dict, context):
    people=[]
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

            people.extend(data.get("values", []))
            nextCursor = data.get("nextCursor")
            if not nextCursor:
                break
        else:
            raise Exception(f"Failed to fetch people: {response.status_code}, {response.text}")

    # print(people)
    print(f"Total number of people fetched: {len(people)}")

    # active_people = [person for person in people if not person.get('isArchived', False)]

    # print(f"Total number of active people fetched: {len(active_people)}")

    people_df = pd.DataFrame(people)

    harvest_ids = people_df["references"].apply(get_harvest_id)
    people_df["harvest_id"] = harvest_ids
    people_df = people_df.drop(columns=["references", "tags"])

    write_to_bigquery(config, people_df, "WRITE_TRUNCATE")
    print(config["dataset_id"])
    print("Done")


if __name__ == "__main__":
    main({}, None)
