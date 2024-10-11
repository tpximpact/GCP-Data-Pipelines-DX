resource "google_bigquery_table" "runn_contracts" {
  dataset_id = google_bigquery_dataset.runn_raw.dataset_id
  table_id   = "contracts"

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

resource "google_bigquery_table" "runn_people" {
  dataset_id = google_bigquery_dataset.runn_raw.dataset_id
  table_id   = "people"

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

resource "google_bigquery_table" "runn_assignments_new" {
  dataset_id = google_bigquery_dataset.runn_raw.dataset_id
  table_id   = "assignments_new"

  time_partitioning {
    type          = "MONTH"
    field         = "startDate"
  }

  schema = <<EOF
[
  {
    "name": "id",
    "type": "INTEGER",
    "mode": "NULLABLE"
  },
  {
    "name": "personId",
    "type": "INTEGER",
    "mode": "NULLABLE"
  },
  {
    "name": "startDate",
    "type": "TIMESTAMP",
    "mode": "NULLABLE"
  },
  {
    "name": "endDate",
    "type": "TIMESTAMP",
    "mode": "NULLABLE"
  },
  {
    "name": "projectId",
    "type": "INTEGER",
    "mode": "NULLABLE"
  },
  {
    "name": "minutesPerDay",
    "type": "INTEGER",
    "mode": "NULLABLE"
  },
  {
    "name": "roleId",
    "type": "INTEGER",
    "mode": "NULLABLE"
  },
  {
    "name": "isActive",
    "type": "BOOLEAN",
    "mode": "NULLABLE"
  },
  {
    "name": "note",
    "type": "STRING",
    "mode": "NULLABLE"
  },
  {
    "name": "isBillable",
    "type": "BOOLEAN",
    "mode": "NULLABLE"
  },
  {
    "name": "phaseId",
    "type": "FLOAT",
    "mode": "NULLABLE"
  },
  {
    "name": "isNonWorkingDay",
    "type": "BOOLEAN",
    "mode": "NULLABLE"
  },
  {
    "name": "isTemplate",
    "type": "BOOLEAN",
    "mode": "NULLABLE"
  },
  {
    "name": "isPlaceholder",
    "type": "BOOLEAN",
    "mode": "NULLABLE"
  },
  {
    "name": "workstreamId",
    "type": "INTEGER",
    "mode": "NULLABLE"
  },
  {
    "name": "createdAt",
    "type": "TIMESTAMP",
    "mode": "NULLABLE"
  },
  {
    "name": "updatedAt",
    "type": "TIMESTAMP",
    "mode": "NULLABLE"
  },
  {
    "name": "uniqueId",
    "type": "STRING",
    "mode": "NULLABLE"
  },
  {
    "name": "importDate",
    "type": "TIMESTAMP",
    "mode": "NULLABLE"
  },
  {
    "name": "numberDays",
    "type": "INTEGER",
    "mode": "NULLABLE"
  },
  {
    "name": "isDeleted",
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

resource "google_bigquery_table" "runn_assignments_process_table" {
  dataset_id = google_bigquery_dataset.runn_raw.dataset_id
  table_id   = "assignments_process_table"

  time_partitioning {
    type          = "MONTH"
    field         = "startDate"
  }

  schema = <<EOF
[
  {
    "name": "id",
    "type": "INTEGER",
    "mode": "NULLABLE"
  },
  {
    "name": "personId",
    "type": "INTEGER",
    "mode": "NULLABLE"
  },
  {
    "name": "startDate",
    "type": "TIMESTAMP",
    "mode": "NULLABLE"
  },
  {
    "name": "endDate",
    "type": "TIMESTAMP",
    "mode": "NULLABLE"
  },
  {
    "name": "projectId",
    "type": "INTEGER",
    "mode": "NULLABLE"
  },
  {
    "name": "minutesPerDay",
    "type": "INTEGER",
    "mode": "NULLABLE"
  },
  {
    "name": "roleId",
    "type": "INTEGER",
    "mode": "NULLABLE"
  },
  {
    "name": "isActive",
    "type": "BOOLEAN",
    "mode": "NULLABLE"
  },
  {
    "name": "note",
    "type": "STRING",
    "mode": "NULLABLE"
  },
  {
    "name": "isBillable",
    "type": "BOOLEAN",
    "mode": "NULLABLE"
  },
  {
    "name": "phaseId",
    "type": "FLOAT",
    "mode": "NULLABLE"
  },
  {
    "name": "isNonWorkingDay",
    "type": "BOOLEAN",
    "mode": "NULLABLE"
  },
  {
    "name": "isTemplate",
    "type": "BOOLEAN",
    "mode": "NULLABLE"
  },
  {
    "name": "isPlaceholder",
    "type": "BOOLEAN",
    "mode": "NULLABLE"
  },
  {
    "name": "workstreamId",
    "type": "INTEGER",
    "mode": "NULLABLE"
  },
  {
    "name": "createdAt",
    "type": "TIMESTAMP",
    "mode": "NULLABLE"
  },
  {
    "name": "updatedAt",
    "type": "TIMESTAMP",
    "mode": "NULLABLE"
  },
  {
    "name": "uniqueId",
    "type": "STRING",
    "mode": "NULLABLE"
  },
  {
    "name": "importDate",
    "type": "TIMESTAMP",
    "mode": "NULLABLE"
  },
  {
    "name": "numberDays",
    "type": "INTEGER",
    "mode": "NULLABLE"
  },
  {
    "name": "isDeleted",
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

resource "google_bigquery_table" "runn_assignments_latest_by_day_table" {
  dataset_id = google_bigquery_dataset.runn_processed.dataset_id
  table_id   = "assignments_latest_by_day"

  time_partitioning {
    type          = "MONTH"
    field         = "start_date"
  }

  schema = <<EOF
[
  {
    "name": "id",
    "type": "INTEGER",
    "mode": "NULLABLE"
  },
  {
    "name": "person_id",
    "type": "INTEGER",
    "mode": "NULLABLE"
  },
  {
    "name": "start_date",
    "type": "TIMESTAMP",
    "mode": "NULLABLE"
  },
  {
    "name": "project_id",
    "type": "INTEGER",
    "mode": "NULLABLE"
  },
  {
    "name": "minutes_per_day",
    "type": "INTEGER",
    "mode": "NULLABLE"
  },
  {
    "name": "role_id",
    "type": "INTEGER",
    "mode": "NULLABLE"
  },
  {
    "name": "is_active",
    "type": "BOOLEAN",
    "mode": "NULLABLE"
  },
  {
    "name": "note",
    "type": "STRING",
    "mode": "NULLABLE"
  },
  {
    "name": "is_billable",
    "type": "BOOLEAN",
    "mode": "NULLABLE"
  },
  {
    "name": "phase_id",
    "type": "FLOAT",
    "mode": "NULLABLE"
  },
  {
    "name": "is_non_working_day",
    "type": "BOOLEAN",
    "mode": "NULLABLE"
  },
  {
    "name": "is_template",
    "type": "BOOLEAN",
    "mode": "NULLABLE"
  },
  {
    "name": "is_placeholder",
    "type": "BOOLEAN",
    "mode": "NULLABLE"
  },
  {
    "name": "workstream_id",
    "type": "INTEGER",
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

resource "google_bigquery_table" "runn_clients" {
  dataset_id = google_bigquery_dataset.runn_raw.dataset_id
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

resource "google_bigquery_table" "runn_public_holidays" {
  dataset_id = google_bigquery_dataset.runn_raw.dataset_id
  table_id   = "public_holidays"

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

resource "google_bigquery_table" "runn_rate_cards" {
  dataset_id = google_bigquery_dataset.runn_raw.dataset_id
  table_id   = "rate_cards"

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

resource "google_bigquery_table" "runn_rate_project_rates" {
  dataset_id = google_bigquery_dataset.runn_raw.dataset_id
  table_id   = "rate_project_rates"

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

resource "google_bigquery_table" "runn_roles" {
  dataset_id = google_bigquery_dataset.runn_raw.dataset_id
  table_id   = "roles"

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

