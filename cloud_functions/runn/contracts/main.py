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
        "url": "https://api.runn.io/contracts?limit=200",
        "headers": runn_headers(project_id, service),
        "dataset_id": os.environ.get("DATASET_ID"),
        "gcp_project": project_id,
        "table_name": os.environ.get("TABLE_NAME"),
        "location": os.environ.get("TABLE_LOCATION"),
        "service": service,
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

        people_df = pd.DataFrame(people)
        people_df["day_monday"] = people_df.rosteredDays.apply(lambda x: x["monday"])
        people_df["day_tuesday"] = people_df.rosteredDays.apply(lambda x: x["tuesday"])
        people_df["day_wednesday"] = people_df.rosteredDays.apply(lambda x: x["wednesday"])
        people_df["day_thursday"] = people_df.rosteredDays.apply(lambda x: x["thursday"])
        people_df["day_friday"] = people_df.rosteredDays.apply(lambda x: x["friday"])
        people_df = people_df.drop(columns=["rosteredDays"])

        write_to_bigquery(config, people_df, "WRITE_TRUNCATE")
        handle_runn_rate_limits(response)

        print(f"Total number of contracts fetched: {len(people_df)}")


if __name__ == "__main__":
    main({}, None)
