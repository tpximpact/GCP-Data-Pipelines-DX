resource "google_bigquery_table" "runn_people" {
  dataset_id = google_bigquery_dataset.runn_raw.dataset_id
  table_id   = "people"

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

resource "google_bigquery_table" "runn_projects" {
  dataset_id = google_bigquery_dataset.runn_raw.dataset_id
  table_id   = "projects"

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


resource "google_bigquery_table" "runn_assignments" {
  dataset_id = google_bigquery_dataset.runn_raw.dataset_id
  table_id   = "assignments"

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

resource "google_bigquery_table" "runn_actuals" {
  dataset_id = google_bigquery_dataset.runn_raw.dataset_id
  table_id   = "actuals"

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

resource "google_bigquery_table" "runn_teams" {
  dataset_id = google_bigquery_dataset.runn_raw.dataset_id
  table_id   = "teams"

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


# Processed assignments table
resource "google_bigquery_table" "runn_processed_assignments" {
  dataset_id = google_bigquery_dataset.runn_processed.dataset_id
  table_id   = "processed_assignments"

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
