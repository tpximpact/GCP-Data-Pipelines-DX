from __future__ import annotations

from dotenv import load_dotenv
import os
from datetime import datetime, timezone
from itertools import batched
from typing import Any, Iterable, cast

import pandas as pd

from data_pipeline_tools.auth import runn_headers
from data_pipeline_tools.bigquery_helpers import bigquery_client_get, write_to_bigquery
from data_pipeline_tools.runn_tools import fetch_all, reference_value_get
from data_pipeline_tools.util import target_daily_partition

BATCH_SIZE = 50

load_dotenv()

PROJECT_ID = os.environ["GOOGLE_CLOUD_PROJECT"]
DATASET_ID = "Runn_Raw"
TABLE_NAME = "projects"
SERVICE_NAME = "Data Pipeline - Projects"
TABLE_LOCATION = os.environ["TABLE_LOCATION"]
RUNN_API_TOKEN = os.environ["RUNN_API_TOKEN"]


def load_config(project_id: str, service: str, ingest_time: datetime) -> dict[str, Any]:
    return {
        "headers": runn_headers(project_id, service),
        "dataset_id": DATASET_ID,
        "gcp_project": project_id,
        "table_name": target_daily_partition(TABLE_NAME, ingest_time),
        "location": TABLE_LOCATION,
        "service": service,
    }


def job_number_get(customFields):
    job_number = ""

    for row in customFields:
        if row["id"] == 2785:
            job_number = row["value"]

    return job_number


def get_first_project_tag(tags):
    if tags:
        if tags[0]["name"] in ["Project", "Retainer"]:
            return str(tags[0]["name"])

    return "No tag"


def process_dataframe(df):

    df["id"] = df["id"].astype("Int64")
    df["name"] = df["name"].astype(str)
    df["isTemplate"] = df["isTemplate"].astype(bool)
    df["isArchived"] = df["isArchived"].astype(bool)
    df["isConfirmed"] = df["isConfirmed"].astype(bool)
    df["pricingModel"] = df["pricingModel"].astype(str)
    df["rateType"] = df["rateType"].astype(str)
    df["teamId"] = df["teamId"].astype("Int64")
    df["budget"] = pd.to_numeric(df["budget"], errors="coerce")
    df["expensesBudget"] = pd.to_numeric(df["expensesBudget"], errors="coerce")
    df["clientId"] = df["clientId"].astype("Int64")
    df["rateCardId"] = df["rateCardId"].astype("Int64")
    df["createdAt"] = df["createdAt"].apply(lambda dateString: pd.Timestamp(dateString))
    df["updatedAt"] = df["updatedAt"].apply(lambda dateString: pd.Timestamp(dateString))

    df["harvestId"] = df["references"].apply(
        lambda references: reference_value_get("Harvest", references)
    )
    df["externalId"] = df["references"].apply(
        lambda references: reference_value_get("externalId", references)
    )
    df["jobNumber"] = df["customFields"].apply(
        lambda customFields: job_number_get(customFields["text"])
    )
    # Ignore projectType
    df["projectType"] = df["tags"].apply(get_first_project_tag)
    df["tags"] = df["tags"].apply(lambda tags: tags if tags is not None else [])
    df = df.drop(columns=["references", "customFields"])


    return df


def main(data: dict | None = None, context: object | None = None) -> None:
    now = datetime.now(timezone.utc)
    config = load_config(PROJECT_ID, SERVICE_NAME, now)

    bigquery_client = bigquery_client_get(location=config["location"])

    pages = fetch_all(
        token=RUNN_API_TOKEN,
        base_url="https://api.runn.io/projects/",
        service=SERVICE_NAME,
        page_size=200,
    )

    for batch_num, batch in enumerate(batched(pages, BATCH_SIZE)):
        write_disposition = "WRITE_TRUNCATE_DATA" if batch_num == 0 else "WRITE_APPEND"

        df = pd.concat(batch)
        processed_df = process_dataframe(df)

        write_to_bigquery(
            client=bigquery_client,
            dataset_id=config["dataset_id"],
            table_name=config["table_name"],
            df=processed_df,
            write_disposition=write_disposition,
        )


if __name__ == "__main__":
    main({}, None)
