resource "google_bigquery_table" "hubspot_deals" {
  dataset_id = google_bigquery_dataset.hubspot_raw.dataset_id
  table_id   = "hubspot_deals"

  time_partitioning {
    type = "DAY"
  }

  labels = {
    env = var.env
  }

  deletion_protection = false

  encryption_configuration {
    kms_key_name = google_kms_crypto_key.bigquery_key.id
  }
}

resource "google_bigquery_table" "hubspot_sales_pipeline" {
  dataset_id = google_bigquery_dataset.hubspot_raw.dataset_id
  table_id   = "hubspot_sales_pipeline"

  time_partitioning {
    type = "DAY"
  }

  labels = {
    env = var.env
  }

  deletion_protection = false

  encryption_configuration {
    kms_key_name = google_kms_crypto_key.bigquery_key.id
  }
}
