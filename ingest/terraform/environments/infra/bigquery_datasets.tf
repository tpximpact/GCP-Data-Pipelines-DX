
resource "google_bigquery_dataset" "runn_raw" {
  dataset_id  = "Runn_Raw"
  description = "Dataset for tables containing raw runn data"
  location    = "europe-west2"

  labels = {
    env = var.env
  }
  default_encryption_configuration {
    kms_key_name = google_kms_crypto_key.bigquery_key.id
  }
}

resource "google_bigquery_dataset" "hubspot_raw" {
  dataset_id  = "Hubspot_Raw"
  description = "Dataset for hubspot raw data"
  location    = "europe-west2"

  labels = {
    env = var.env
  }
  default_encryption_configuration {
    kms_key_name = google_kms_crypto_key.bigquery_key.id
  }
}

resource "google_bigquery_dataset" "google_sheets_presentation" {
  dataset_id = "Google_Sheets_Presentation"
  description = "Dataset for google sheets bigquery connected-sheets"
  location = "europe-west2"

  labels = {
    env = var.env
  }
  default_encryption_configuration {
    kms_key_name = google_kms_crypto_key.bigquery_key.id
  }
}

resource "google_bigquery_dataset" "googlesheets_raw" {
  dataset_id = "GoogleSheets_Raw"
  description = "Dataset for raw data imported from a google-sheet google sheets bigquery connected-sheets"
  location = "europe-west2"

  labels = {
    env = var.env
  }
  default_encryption_configuration {
    kms_key_name = google_kms_crypto_key.bigquery_key.id
  }
}
