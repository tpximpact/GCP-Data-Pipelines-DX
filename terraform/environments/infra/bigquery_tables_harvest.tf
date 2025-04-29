# --------------------------clients table --------------------------------\
resource "google_bigquery_table" "harvest_clients" {
  dataset_id = google_bigquery_dataset.harvest_raw.dataset_id
  table_id   = "clients"

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

# --------------------------expenses table --------------------------------\
resource "google_bigquery_table" "harvest_expenses" {
  dataset_id = google_bigquery_dataset.harvest_raw.dataset_id
  table_id   = "expenses"

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

# --------------------------projects table --------------------------------\
resource "google_bigquery_table" "harvest_projects" {
  dataset_id = google_bigquery_dataset.harvest_raw.dataset_id
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

# --------------------------reports table --------------------------------\
resource "google_bigquery_table" "harvest_reports" {
  dataset_id = google_bigquery_dataset.harvest_raw.dataset_id
  table_id   = "reports"

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

# --------------------------timesheets table --------------------------------\
resource "google_bigquery_table" "harvest_timesheets" {
  dataset_id = google_bigquery_dataset.harvest_raw.dataset_id
  table_id   = "timesheets"

#  time_partitioning {
#    type          = "MONTH"
#    field         = "spent_date"
#  }

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

# --------------------------user_project_assignments table --------------------------------\
resource "google_bigquery_table" "harvest_user_project_assignments" {
  dataset_id = google_bigquery_dataset.harvest_raw.dataset_id
  table_id   = "user_project_assignments"

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

# --------------------------users table --------------------------------\
resource "google_bigquery_table" "harvest_users" {
  dataset_id = google_bigquery_dataset.harvest_raw.dataset_id
  table_id   = "users"

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






