import os
import pandas as pd
from data_pipeline_tools.auth import access_secret_version
from data_pipeline_tools.util import (write_to_bigquery, find_and_flatten_columns) 
from hubspot import HubSpot
from hubspot.crm.pipelines import ApiException
from pprint import pprint
    
project_id = os.environ.get("GOOGLE_CLOUD_PROJECT")

if not project_id:
    project_id = "tpx-dx-dashboards"

def load_config(project_id, service) -> dict:
  return {
    "dataset_id": "Hubspot_Raw",#os.environ.get("DATASET_ID"),
    "gcp_project": project_id,
    "table_name": "hubspot_sales_pipeline", #os.environ.get("TABLE_NAME"),
    "location": "europe-west2", #os.environ.get("TABLE_LOCATION"),
    "service": service,
  }


def main(data: dict, context: dict = None):
  service = "Data Pipeline - HubSpot deals"
  config = load_config(project_id, service)
  hubspot_token = access_secret_version(project_id, "HUBSPOT_TOKEN")
  api_client = HubSpot(access_token=hubspot_token)
  print(hubspot_token)
  try:
    api_response = api_client.crm.pipelines.pipeline_stages_api.get_all(object_type="deals", pipeline_id="default")
   
    stages = [x.to_dict() for x in api_response.results]
    df = pd.DataFrame(stages)
    df = find_and_flatten_columns(df)
    write_to_bigquery(config, df, "WRITE_TRUNCATE")

  except ApiException as e:
    print("Exception when calling pipelines_api->get_all: %s\n" % e)


if __name__ == "__main__":
    main({})
