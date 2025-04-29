import os
from hubspot import HubSpot
from hubspot.crm.deals import ApiException
import pandas as pd

from data_pipeline_tools.auth import access_secret_version
from datetime import datetime, timezone

from data_pipeline_tools.util import (
  read_from_bigquery
)

from data_pipeline_tools.bigquery_helpers import (
  bigquery_client_get
)

    
project_id = os.environ.get("GOOGLE_CLOUD_PROJECT")

if not project_id:
    project_id = "tpx-dx-dashboards"


def load_config(project_id, service) -> dict:
  return {
    "gcp_project": project_id,
    "location": "europe-west2", #os.environ.get("TABLE_LOCATION"),
    "service": service,
  }


def main(data: dict, context: dict = None):
  service = "Data Pipeline - HubSpot data_sync"
  config  = load_config(project_id, service)

  print("Hello form the Hubspot data sync")

  bigquery_client = bigquery_client_get(location=config["location"])

  actuals_to_date_query      = f"""SELECT * FROM tpx-dx-dashboards.Harvest_Processed.actuals_by_project_to_date"""
  total_forecasted_query     = f"""SELECT * FROM tpx-dx-dashboards.Runn_Processed.total_forecasted_by_project"""
  remaining_forecasted_query = f"""SELECT * FROM tpx-dx-dashboards.Runn_Processed.remaining_forcasted_by_project"""

  actuals_to_date      = read_from_bigquery(project_id, actuals_to_date_query)
  total_forecasted     = read_from_bigquery(project_id, total_forecasted_query)
  remaining_forecasted = read_from_bigquery(project_id, remaining_forecasted_query)

  print(f"Actuals to date length: {len(actuals_to_date.index)}")
  print(f"Total forecasted length: {len(total_forecasted.index)}")
  print(f"Remaining forecasted length: {len(remaining_forecasted.index)}")



#   hubspot_token = access_secret_version(project_id, "HUBSPOT_TOKEN")
#
#   api_client = HubSpot(access_token=hubspot_token)
#   config = load_config(project_id, service)
#   import_date = datetime.now(timezone.utc).strftime('%Y-%m-%dT%H:%M:%SZ')


#
#   except ApiException as e:
#     print("Exception when calling basic_api->get_page: %s\n" % e)


if __name__ == "__main__":
    main({})
