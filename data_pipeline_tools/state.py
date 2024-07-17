from google.cloud import bigquery
from datetime import datetime, timezone, date

progress_table = "tpx-dx-dashboards.State.process_state"

def state_get(id):
  client = bigquery.Client()

  query = f"SELECT next_page, UNIX_SECONDS(updated_since) as updated_since, UNIX_SECONDS(batch_start_time) as batch_start_time FROM `{progress_table}` WHERE id = '{id}'"
  query_job = client.query(query)
  result = list(query_job.result())

  for row in result:
      return row.next_page, row.updated_since, row.batch_start_time

  return None, None, None

def state_update(id, next_page, updated_since, batch_start_time):
    client = bigquery.Client()

    now = int(round(datetime.now(timezone.utc).timestamp()))

    page_update = "page_number = page_number + 1"

    if not next_page:
        updated_since = batch_start_time
        batch_start_time = now
        page_update = "page_number = 0"


    if not batch_start_time:
        batch_start_time = now

    last_processed_time = now


    if updated_since:
        query = f"""
            UPDATE `{progress_table}`
            SET
                next_page = '{next_page}',
                batch_start_time = TIMESTAMP_SECONDS({batch_start_time}),
                updated_since = TIMESTAMP_SECONDS({updated_since}),
                last_processed_time = TIMESTAMP_SECONDS({last_processed_time}),
                {page_update}
            WHERE id = '{id}'
        """
    else :
        query = f"""
            UPDATE `{progress_table}`
            SET
                next_page = '{next_page}',
                batch_start_time = TIMESTAMP_SECONDS({batch_start_time}),
                last_processed_time = TIMESTAMP_SECONDS({last_processed_time}),
                {page_update}
            WHERE id = '{id}'
        """

    print(query)

    query_job = client.query(query)
    query_job.result()