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
    "name": "uniqueId",
    "type": "STRING",
    "mode": "NULLABLE"
  },
  {
    "name": "id",
    "type": "INT64",
    "mode": "NULLABLE",
    "description": "Item ID"
  },
  {
    "name": "personId",
    "type": "INT64",
    "mode": "NULLABLE",
    "description": "Person ID"
  },
  {
    "name": "startDate",
    "type": "TIMESTAMP",
    "description": "Assignment start date"
  },
  {
    "name": "endDate",
    "type": "TIMESTAMP",
    "description": "Assignment end date"
  },
  {
    "name": "projectId",
    "type": "INT64",
    "mode": "NULLABLE"
  },
  {
    "name": "numberDays",
    "type": "INT64",
    "mode": "NULLABLE"
  },
  {
    "name": "minutesPerDay",
    "type": "INT64",
    "mode": "NULLABLE"
  },
  {
    "name": "roleId",
    "type": "INT64",
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
    "type": "INT64",
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
    "type": "INT64",
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
    "name": "importDate",
    "type": "TIMESTAMP",
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

