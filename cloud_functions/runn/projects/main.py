import os
import pandas as pd

from datetime import datetime, timezone
from data_pipeline_tools.auth import runn_headers, access_secret_version

from data_pipeline_tools.bigquery_helpers import bigquery_client_get, write_to_bigquery
from data_pipeline_tools.util import target_daily_partition

from data_pipeline_tools.runn_tools import reference_value_get
from data_pipeline_tools.runn_tools import fetch_all
from itertools import batched

BATCH_SIZE = 50

project_id = os.environ.get("GOOGLE_CLOUD_PROJECT") or "tpx-dx-dashboards"


def load_config(project_id, service) -> dict:
    return {
        "headers": runn_headers(project_id, service),
        "dataset_id": (os.environ.get("DATASET_ID") or "Runn_Raw"),
        "gcp_project": project_id,
        "table_name": os.environ.get("TABLE_NAME") or "projects",
        "location": (os.environ.get("TABLE_LOCATION") or "europe-west2"),
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


def date_pd_timestamp(dateString):
    return pd.Timestamp(dateString)


def spent_date_pd_timestamp(dateString):
    return pd.Timestamp(f"{dateString}T00:00:00Z")


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


def main(data: dict, context):
    service = "Data Pipeline - Projects"
    now = datetime.now(timezone.utc)
    config = load_config(project_id, service)

    runn_api_token = access_secret_version(project_id, "RUNN_ACCESS_TOKEN")
    bigquery_client = bigquery_client_get(location=config["location"])

    pages = fetch_all(
        token=runn_api_token,
        base_url="https://api.runn.io/projects/",
        service=service,
        # Max page_size for /projects is 200
        page_size=200,
    )

    for batch_num, batch in enumerate(batched(pages, BATCH_SIZE)):
        # First frame truncates partition
        # Subsequent frames append
        disposition = "WRITE_TRUNCATE_DATA" if batch_num == 0 else "WRITE_APPEND"

        df = pd.concat(batch)
        processed_df = process_dataframe(df)

        write_to_bigquery(
            client=bigquery_client,
            dataset_id=config["dataset_id"],
            table_name=target_daily_partition(config["table_name"], now),
            df=processed_df,
            write_disposition=disposition,
        )


if __name__ == "__main__":
    main({}, None)
