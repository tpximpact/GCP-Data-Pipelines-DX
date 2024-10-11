# --------------------------assignments table --------------------------------\
resource "google_bigquery_table" "runn_assignments" {
  dataset_id = google_bigquery_dataset.runn_raw.dataset_id
  table_id   = "assignments"

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
      "type": "INTEGER",
      "mode": "NULLABLE"
    },
    {
      "name": "personId",
      "type": "INTEGER",
      "mode": "NULLABLE"
    },
    {
      "name": "projectId",
      "type": "INTEGER",
      "mode": "NULLABLE"
    },
    {
      "name": "roleId",
      "type": "INTEGER",
      "mode": "NULLABLE"
    },
    {
      "name": "phaseId",
      "type": "FLOAT",
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
      "name": "minutesPerDay",
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

# --------------------------assignments_data_lake table --------------------------------\
resource "google_bigquery_table" "run_assignments_data_lake" {
  dataset_id = google_bigquery_dataset.runn_raw.dataset_id
  table_id   = "assignments_data_lake"

  time_partitioning {
    type          = "MONTH"
    field         = "startDate"
  }

  schema = google_bigquery_table.runn_assignments.schema

  labels = {
    env = var.env
  }

  deletion_protection = false

  encryption_configuration {
    kms_key_name = google_kms_crypto_key.bigquery_key.id
  }
}

# --------------------------clients table --------------------------------\
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

# --------------------------contracts table --------------------------------\
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

# --------------------------people table --------------------------------\
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

# --------------------------projects table --------------------------------\
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

# --------------------------project_rates table --------------------------------\
resource "google_bigquery_table" "runn_project_rates" {
  dataset_id = google_bigquery_dataset.runn_raw.dataset_id
  table_id   = "project_rates"

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

# --------------------------public_holidays table --------------------------------\
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

# --------------------------rate_cards table --------------------------------\
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


# --------------------------roles table --------------------------------\
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

# --------------------------teams table --------------------------------\
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


