# -------------------------- runn_clients_normalised --------------------------------\
resource "google_bigquery_data_transfer_config" "runn_clients_normalised" {
  display_name           = "runn_clients_normalised"
  location               = google_bigquery_dataset.runn_processed.location
  data_source_id         = "scheduled_query"
  service_account_name   = "bq-transfer@tpx-dx-dashboards.iam.gserviceaccount.com"
  schedule               = "every day 03:00"
  destination_dataset_id = google_bigquery_dataset.runn_processed.dataset_id

  params = {
    destination_table_name_template = "clients_normalised"
    write_disposition               = "WRITE_APPEND"
    query                           =  file("${path.module}/queries/runn_clients_normalised.sql")
  }
}

# -------------------------- runn_people_normalised --------------------------------\
resource "google_bigquery_data_transfer_config" "runn_people_normalised" {
  display_name           = "runn_people_normalised"
  location               = google_bigquery_dataset.runn_processed.location
  data_source_id         = "scheduled_query"
  service_account_name   = "bq-transfer@tpx-dx-dashboards.iam.gserviceaccount.com"
  schedule               = "every day 03:00"
  destination_dataset_id = google_bigquery_dataset.runn_processed.dataset_id

  params = {
    destination_table_name_template = "people_normalised"
    write_disposition               = "WRITE_APPEND"
    query                           =  file("${path.module}/queries/runn_people_normalised.sql")
  }
}

# -------------------------- runn_projects_normalised --------------------------------\
resource "google_bigquery_data_transfer_config" "runn_projects_normalised" {
  display_name           = "runn_projects_normalised"
  location               = google_bigquery_dataset.runn_processed.location
  data_source_id         = "scheduled_query"
  service_account_name   = "bq-transfer@tpx-dx-dashboards.iam.gserviceaccount.com"
  schedule               = "every day 03:00"
  destination_dataset_id = google_bigquery_dataset.runn_processed.dataset_id

  params = {
    destination_table_name_template = "projects_normalised"
    write_disposition               = "WRITE_APPEND"
    query                           =  file("${path.module}/queries/runn_projects_normalised.sql")
  }
}