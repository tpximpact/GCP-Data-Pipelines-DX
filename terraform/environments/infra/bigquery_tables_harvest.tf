resource "google_bigquery_table" "harvest_timesheets" {
  dataset_id = google_bigquery_dataset.harvest_raw.dataset_id
  table_id   = "timesheets"

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


resource "google_bigquery_table" "harvest_timesheet_data_lake" {
  dataset_id = google_bigquery_dataset.harvest_raw.dataset_id
  table_id   = "timesheet_data_lake"

#  time_partitioning {
#    type = "DAY"
#  }

  labels = {
    env = var.env
  }

  deletion_protection = false

  encryption_configuration {
    kms_key_name = google_kms_crypto_key.bigquery_key.id
  }
}

resource "google_bigquery_table" "harvest_timesheet_data_lake_new" {
  dataset_id = google_bigquery_dataset.harvest_raw.dataset_id
  table_id   = "timesheet_data_lake_new"

  time_partitioning {
    type          = "MONTH"
    field         = "spent_date"
  }

  schema = <<EOF
[
  {
    "name": "id",
    "type": "INTEGER",
    "mode": "NULLABLE"
  },
  {
    "name": "spent_date",
    "type": "TIMESTAMP",
    "mode": "NULLABLE"
  },
  {
    "name": "hours",
    "type": "FLOAT",
    "mode": "NULLABLE"
  },
  {
    "name": "hours_without_timer",
    "type": "FLOAT",
    "mode": "NULLABLE"
  },
  {
    "name": "rounded_hours",
    "type": "FLOAT",
    "mode": "NULLABLE"
  },
  {
    "name": "notes",
    "type": "STRING",
    "mode": "NULLABLE"
  },
  {
    "name": "is_locked",
    "type": "BOOLEAN",
    "mode": "NULLABLE"
  },
  {
    "name": "locked_reason",
    "type": "STRING",
    "mode": "NULLABLE"
  },
  {
    "name": "is_closed",
    "type": "BOOLEAN",
    "mode": "NULLABLE"
  },
  {
    "name": "is_billed",
    "type": "BOOLEAN",
    "mode": "NULLABLE"
  },
  {
    "name": "is_running",
    "type": "BOOLEAN",
    "mode": "NULLABLE"
  },
  {
    "name": "billable",
    "type": "BOOLEAN",
    "mode": "NULLABLE"
  },
  {
    "name": "budgeted",
    "type": "BOOLEAN",
    "mode": "NULLABLE"
  },
  {
    "name": "billable_rate",
    "type": "FLOAT",
    "mode": "NULLABLE"
  },
  {
    "name": "cost_rate",
    "type": "FLOAT",
    "mode": "NULLABLE"
  },
  {
    "name": "created_at",
    "type": "TIMESTAMP",
    "mode": "NULLABLE"
  },
  {
    "name": "updated_at",
    "type": "TIMESTAMP",
    "mode": "NULLABLE"
  },
  {
    "name": "unique_id",
    "type": "STRING",
    "mode": "NULLABLE"
  },
  {
    "name": "import_date",
    "type": "TIMESTAMP",
    "mode": "NULLABLE"
  },
  {
    "name": "user_id",
    "type": "INTEGER",
    "mode": "NULLABLE"
  },
  {
    "name": "user_name",
    "type": "STRING",
    "mode": "NULLABLE"
  },
  {
    "name": "client_id",
    "type": "INTEGER",
    "mode": "NULLABLE"
  },
  {
    "name": "client_name",
    "type": "STRING",
    "mode": "NULLABLE"
  },
  {
    "name": "client_currency",
    "type": "STRING",
    "mode": "NULLABLE"
  },
  {
    "name": "project_id",
    "type": "INTEGER",
    "mode": "NULLABLE"
  },
  {
    "name": "project_name",
    "type": "STRING",
    "mode": "NULLABLE"
  },
  {
    "name": "project_code",
    "type": "STRING",
    "mode": "NULLABLE"
  },
  {
    "name": "task_id",
    "type": "INTEGER",
    "mode": "NULLABLE"
  },
  {
    "name": "task_name",
    "type": "STRING",
    "mode": "NULLABLE"
  },
  {
    "name": "is_deleted",
    "type": "BOOLEAN",
    "mode": "NULLABLE"
  }
]
EOF
  labels = {
    env = var.env
  }

  deletion_protection = false

  encryption_configuration {
    kms_key_name = google_kms_crypto_key.bigquery_key.id
  }
}

resource "google_bigquery_table" "harvest_timesheet_data_lake_process_table" {
  dataset_id = google_bigquery_dataset.harvest_raw.dataset_id
  table_id   = "timesheet_data_lake_process_table"

  time_partitioning {
    type          = "MONTH"
    field         = "spent_date"
  }

  schema = <<EOF
[
  {
    "name": "id",
    "type": "INTEGER",
    "mode": "NULLABLE"
  },
  {
    "name": "spent_date",
    "type": "TIMESTAMP",
    "mode": "NULLABLE"
  },
  {
    "name": "hours",
    "type": "FLOAT",
    "mode": "NULLABLE"
  },
  {
    "name": "hours_without_timer",
    "type": "FLOAT",
    "mode": "NULLABLE"
  },
  {
    "name": "rounded_hours",
    "type": "FLOAT",
    "mode": "NULLABLE"
  },
  {
    "name": "notes",
    "type": "STRING",
    "mode": "NULLABLE"
  },
  {
    "name": "is_locked",
    "type": "BOOLEAN",
    "mode": "NULLABLE"
  },
  {
    "name": "locked_reason",
    "type": "STRING",
    "mode": "NULLABLE"
  },
  {
    "name": "is_closed",
    "type": "BOOLEAN",
    "mode": "NULLABLE"
  },
  {
    "name": "is_billed",
    "type": "BOOLEAN",
    "mode": "NULLABLE"
  },
  {
    "name": "is_running",
    "type": "BOOLEAN",
    "mode": "NULLABLE"
  },
  {
    "name": "billable",
    "type": "BOOLEAN",
    "mode": "NULLABLE"
  },
  {
    "name": "budgeted",
    "type": "BOOLEAN",
    "mode": "NULLABLE"
  },
  {
    "name": "billable_rate",
    "type": "FLOAT",
    "mode": "NULLABLE"
  },
  {
    "name": "cost_rate",
    "type": "FLOAT",
    "mode": "NULLABLE"
  },
  {
    "name": "created_at",
    "type": "TIMESTAMP",
    "mode": "NULLABLE"
  },
  {
    "name": "updated_at",
    "type": "TIMESTAMP",
    "mode": "NULLABLE"
  },
  {
    "name": "unique_id",
    "type": "STRING",
    "mode": "NULLABLE"
  },
  {
    "name": "import_date",
    "type": "TIMESTAMP",
    "mode": "NULLABLE"
  },
  {
    "name": "user_id",
    "type": "INTEGER",
    "mode": "NULLABLE"
  },
  {
    "name": "user_name",
    "type": "STRING",
    "mode": "NULLABLE"
  },
  {
    "name": "client_id",
    "type": "INTEGER",
    "mode": "NULLABLE"
  },
  {
    "name": "client_name",
    "type": "STRING",
    "mode": "NULLABLE"
  },
  {
    "name": "client_currency",
    "type": "STRING",
    "mode": "NULLABLE"
  },
  {
    "name": "project_id",
    "type": "INTEGER",
    "mode": "NULLABLE"
  },
  {
    "name": "project_name",
    "type": "STRING",
    "mode": "NULLABLE"
  },
  {
    "name": "project_code",
    "type": "STRING",
    "mode": "NULLABLE"
  },
  {
    "name": "task_id",
    "type": "INTEGER",
    "mode": "NULLABLE"
  },
  {
    "name": "task_name",
    "type": "STRING",
    "mode": "NULLABLE"
  }
]
EOF
  labels = {
    env = var.env
  }

  deletion_protection = false

  encryption_configuration {
    kms_key_name = google_kms_crypto_key.bigquery_key.id
  }
}

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
