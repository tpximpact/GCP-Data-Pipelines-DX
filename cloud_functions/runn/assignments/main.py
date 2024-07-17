import os
import pandas as pd
import requests
import time
import copy
from datetime import datetime, timezone, date, timedelta

from data_pipeline_tools.auth import runn_headers
from data_pipeline_tools.util import write_to_bigquery
from data_pipeline_tools.state import (
    state_get,
    state_update
)

project_id = os.environ.get("GOOGLE_CLOUD_PROJECT")

if not project_id:
    project_id = "tpx-dx-dashboards"

if not project_id:
    project_id = input("Enter GCP project ID: ")


def load_config(project_id, service) -> dict:
    return {
        "url": "https://api.runn.io/assignments",
        "headers": runn_headers(project_id, service),
        "dataset_id": os.environ.get("DATASET_ID"),
        "gcp_project": project_id,
        "table_name": os.environ.get("TABLE_NAME"),
        "state_table_name": os.environ.get("STATE_TABLE_NAME"),
        "location": os.environ.get("TABLE_LOCATION"),
        "service": service,
    }


def date_to_timestamp(date_string) -> float:
    parsed_date = datetime.fromisoformat(date_string[:-1])
    return parsed_date.timestamp()

def main(data: dict, context):
    service = "Data Pipeline - Assignments"
    config = load_config(project_id, service)
    batch_size = 1

    next_cursor, updated_since, batch_start_time = state_get(config["table_name"])

    max_updated_since = updated_since if updated_since else 0

    if updated_since:
      updated_since = datetime.fromtimestamp(updated_since, timezone.utc).strftime('%Y-%m-%dT%H:%M:%SZ')

    for start_page in range(0, batch_size):
      if next_cursor:
        url = config["url"] + f"?cursor={next_cursor}"
      elif updated_since:
        url = config["url"] + f"?modifiedAfter={updated_since}"
      else:
        url = config["url"]

      print("url", url)

      response = requests.get(url=url, headers=config["headers"])


      if response.status_code == 200:
        data = response.json()
        nextCursor = data.get("nextCursor")

        df = pd.DataFrame(data.get("values", []))

        if df.empty:
          next_cursor = ""
          break

        max_updated_since_new = date_to_timestamp(df["updatedAt"].max())
        max_updated_since = max_updated_since_new if max_updated_since_new > max_updated_since else max_updated_since

        df = expand_rows(df)

        df["unique_id"] = df["id"].astype(str) + "-" + df["startDate"].astype(str) + "-" + df["updatedAt"].astype(str)

        write_to_bigquery(config, df, "WRITE_APPEND")

        if not next_cursor:
          next_cursor = ""
          break

      else:
        raise Exception(f"Failed to fetch assignments: {response.status_code}, {response.text}")

      state_update(config["table_name"], next_cursor, max_updated_since, batch_start_time, next_cursor == "")


def expand_rows(df):
    # When an assignment is entered, it can be put in for a single day or multiple.
    # For entries spanning across multiple days, this function converts to single day entries and returns the dataframe.

    rows_to_edit = df[df["startDate"] != df["endDate"]]
    single_assignment_rows = df[df["startDate"] == df["endDate"]]
    edited_rows = []

    for _, row in rows_to_edit.iterrows():
        # get the times
        end_date = datetime.strptime(row["endDate"], "%Y-%m-%d")
        start_date = datetime.strptime(row["startDate"], "%Y-%m-%d")

        dates = get_dates(start_date, end_date)

        for date in dates:
            edited_rows.append(make_assignments_row(copy.copy(row), date))

    return pd.concat([single_assignment_rows, pd.DataFrame(edited_rows)])


def get_dates(start_date: datetime, end_date: datetime) -> list:
    date = copy.copy(start_date)
    dates_list = []
    while date <= end_date:
        if date.weekday() < 5:
            dates_list.append(date)
        date = date + timedelta(days=1)
    return dates_list


def make_assignments_row(row: pd.Series, date: datetime) -> pd.Series:
    string_date = datetime.strftime(date, "%Y-%m-%d")
    row["startDate"] = string_date
    row["endDate"] = string_date
    return row

if __name__ == "__main__":
    main({}, None)
