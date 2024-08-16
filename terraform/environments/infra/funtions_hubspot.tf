# --------------------------hubspot deals--------------------------------\
# Generates an archive of the source code compressed as a .zip file.
data "archive_file" "hubspot_deals" {
  type        = "zip"
  source_dir  = "../../../cloud_functions/hubspot/deals"
  output_path = "/tmp/hubspot_deals.zip"
}

# Add source code zip to the Cloud Function's bucket
resource "google_storage_bucket_object" "hubspot_deals" {
  source       = data.archive_file.hubspot_deals.output_path
  content_type = "application/zip"

  # Append to the MD5 checksum of the files content
  # to force the zip to be updated as soon as a change occurs
  name   = "cloud_function-${data.archive_file.hubspot_deals.output_md5}.zip"
  bucket = data.google_storage_bucket.function_bucket.name
}

resource "google_cloudfunctions_function" "hubspot_deals" {
  name                = "hubspot_deals_pipe"
  runtime             = "python312" # of course changeable
  available_memory_mb = 512
  timeout             = 540
  # Get the source code of the cloud function as a Zip compression
  source_archive_bucket = data.google_storage_bucket.function_bucket.name
  source_archive_object = google_storage_bucket_object.hubspot_deals.name

  # Must match the function name in the cloud function `main.py` source code
  entry_point                  = "main"
  https_trigger_security_level = "SECURE_ALWAYS"
  event_trigger {
    event_type = "providers/cloud.pubsub/eventTypes/topic.publish"
    resource   = google_pubsub_topic.cloud_function_trigger_tester.id
  }

  environment_variables = {
    "DATASET_ID"           = google_bigquery_dataset.hubspot_raw.dataset_id
    "TABLE_NAME"           = google_bigquery_table.hubspot_deals.table_id
    "TABLE_LOCATION"       = google_bigquery_dataset.hubspot_raw.location
    "STATE_TABLE_NAME"     = "${google_bigquery_dataset.state_tables.dataset_id}.${google_bigquery_table.process_state.table_id}"
    "GOOGLE_CLOUD_PROJECT" = var.project

  }
}


# --------------------------hubspot deals stages--------------------------------\
# Generates an archive of the source code compressed as a .zip file.
data "archive_file" "hubspot_deals_stages" {
  type        = "zip"
  source_dir  = "../../../cloud_functions/hubspot/deals_stages"
  output_path = "/tmp/hubspot_deals_stages.zip"
}

# Add source code zip to the Cloud Function's bucket
resource "google_storage_bucket_object" "hubspot_deals_stages" {
  source       = data.archive_file.hubspot_deals_stages.output_path
  content_type = "application/zip"

  # Append to the MD5 checksum of the files content
  # to force the zip to be updated as soon as a change occurs
  name   = "cloud_function-${data.archive_file.hubspot_deals_stages.output_md5}.zip"
  bucket = data.google_storage_bucket.function_bucket.name
}

resource "google_cloudfunctions_function" "hubspot_deals_stages_pipeline" {
  name                = "hubspot_deals_stages_pipe"
  runtime             = "python312" # of course changeable
  available_memory_mb = 512
  timeout             = 540
  # Get the source code of the cloud function as a Zip compression
  source_archive_bucket = data.google_storage_bucket.function_bucket.name
  source_archive_object = google_storage_bucket_object.hubspot_deals_stages.name

  # Must match the function name in the cloud function `main.py` source code
  entry_point                  = "main"
  https_trigger_security_level = "SECURE_ALWAYS"
  event_trigger {
    event_type = "providers/cloud.pubsub/eventTypes/topic.publish"
    resource   = google_pubsub_topic.cloud_function_trigger_tester.id
  }

  environment_variables = {
    "DATASET_ID"           = google_bigquery_dataset.hubspot_raw.dataset_id
    "TABLE_NAME"           = google_bigquery_table.hubspot_deals_stages.table_id
    "TABLE_LOCATION"       = google_bigquery_dataset.hubspot_raw.location
    "STATE_TABLE_NAME"     = "${google_bigquery_dataset.state_tables.dataset_id}.${google_bigquery_table.process_state.table_id}"
    "GOOGLE_CLOUD_PROJECT" = var.project

  }
}
