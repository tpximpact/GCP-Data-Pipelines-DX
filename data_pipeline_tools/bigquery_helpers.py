import pandas as pd
from google.cloud import bigquery

def bigquery_client_get(location: str) -> bigquery.Client:
 return bigquery.Client(location=location)

def write_to_bigquery(client: bigquery.Client, dataset_id: str, table_name: str, df: pd.DataFrame, write_disposition: str) -> None:

  # Get a reference to the BigQuery table to write to.
  dataset_ref = client.dataset(dataset_id)
  table_ref = dataset_ref.table(table_name)

  # Set up the job configuration with the specified write disposition.
  job_config = bigquery.LoadJobConfig(write_disposition=write_disposition)
  job_config.autodetect = True

  try:
    # Write the DataFrame to BigQuery using the specified configuration.
    job = client.load_table_from_dataframe(df, table_ref, job_config=job_config)
    job.result()

  except BadRequest as e:
    print(f"Error writing DataFrame to BigQuery: {str(e)}")
    return

  # Print a message indicating how many rows were loaded.
  print(
    "Loaded {} rows into {}:{}.".format(
      job.output_rows, dataset_id, table_name
    )
  )