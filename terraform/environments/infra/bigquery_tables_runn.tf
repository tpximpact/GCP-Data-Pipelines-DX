# --------------------------assignments table --------------------------------\
resource "google_bigquery_table" "runn_assignments" {
  dataset_id = google_bigquery_dataset.runn_raw.dataset_id
  table_id   = "assignments"

  time_partitioning {
    type = "DAY"
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

  deletion_protection = true

  encryption_configuration {
    kms_key_name = google_kms_crypto_key.bigquery_key.id
  }
}


# --------------------------actuals table --------------------------------\
resource "google_bigquery_table" "runn_actuals" {
  dataset_id = google_bigquery_dataset.runn_raw.dataset_id
  table_id   = "actuals"

  time_partitioning {
    type = "DAY"
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
      "type": "INTEGER",
      "mode": "NULLABLE"
    },
    {
      "name": "date",
      "type": "TIMESTAMP",
      "mode": "NULLABLE"
    },
    {
      "name": "billableMinutes",
      "type": "INTEGER",
      "mode": "NULLABLE"
    },
    {
      "name": "nonbillableMinutes",
      "type": "INTEGER",
      "mode": "NULLABLE"
    },
    {
      "name": "billableNote",
      "type": "STRING",
      "mode": "NULLABLE"
    },
    {
      "name": "nonbillableNote",
      "type": "STRING",
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

  deletion_protection = true

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

  schema = <<EOF
  [
    {
      "name": "id",
      "type": "INTEGER",
      "mode": "NULLABLE"
    },
    {
      "name": "name",
      "type": "STRING",
      "mode": "NULLABLE"
    },
    {
      "name": "website",
      "type": "STRING",
      "mode": "NULLABLE"
    },
    {
      "name": "isArchived",
      "type": "BOOLEAN",
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
      "name": "harvestId",
      "type": "STRING",
      "mode": "NULLABLE"
    }
  ]
  EOF

  labels = {
    env = var.env
  }

  deletion_protection = true

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

  schema = <<EOF
  [
    {
      "name": "id",
      "type": "INTEGER",
      "mode": "NULLABLE"
    },
    {
      "name": "costPerHour",
      "type": "FLOAT",
      "mode": "NULLABLE"
    },
    {
      "name": "employmentType",
      "type": "STRING",
      "mode": "NULLABLE"
    },
    {
      "name": "minutesPerDay",
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
      "name": "roleId",
      "type": "INTEGER",
      "mode": "NULLABLE"
    },
    {
      "name": "personId",
      "type": "INTEGER",
      "mode": "NULLABLE"
    },
    {
      "name": "jobTitle",
      "type": "STRING",
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
      "name": "day_monday",
      "type": "INTEGER",
      "mode": "NULLABLE"
    },
    {
      "name": "day_tuesday",
      "type": "INTEGER",
      "mode": "NULLABLE"
    },
    {
      "name": "day_wednesday",
      "type": "INTEGER",
      "mode": "NULLABLE"
    },
    {
      "name": "day_thursday",
      "type": "INTEGER",
      "mode": "NULLABLE"
    },
    {
      "name": "day_friday",
      "type": "INTEGER",
      "mode": "NULLABLE"
    }
  ]
  EOF

  labels = {
    env = var.env
  }

  deletion_protection = true

  encryption_configuration {
    kms_key_name = google_kms_crypto_key.bigquery_key.id
  }
}



# --------------------------other project expenses table --------------------------------\
resource "google_bigquery_table" "runn_other_project_expenses" {
  dataset_id = google_bigquery_dataset.runn_raw.dataset_id
  table_id   = "other_project_expenses"

  time_partitioning {
    type = "DAY"
  }

  schema = <<EOF
  [
    {
      "name": "id",
      "type": "INTEGER",
      "mode": "NULLABLE"
    },
    {
      "name": "projectId",
      "type": "INTEGER",
      "mode": "NULLABLE"
    },
    {
      "name": "cost",
      "type": "FLOAT",
      "mode": "NULLABLE"
    },
    {
      "name": "charge",
      "type": "FLOAT",
      "mode": "NULLABLE"
    },
    {
      "name": "name",
      "type": "STRING",
      "mode": "NULLABLE"
    },
    {
      "name": "date",
      "type": "TIMESTAMP",
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
    }
  ]
  EOF


  labels = {
    env = var.env
  }

  deletion_protection = true

  encryption_configuration {
    kms_key_name = google_kms_crypto_key.bigquery_key.id
  }
}

# --------------------------people table --------------------------------\
resource "google_bigquery_table" "runn_people" {
  dataset_id = google_bigquery_dataset.runn_raw.dataset_id
  table_id   = "people"

  time_partitioning {
    type = "DAY"
  }

  schema = <<EOF
  [
    {
      "name": "id",
      "type": "INTEGER",
      "mode": "NULLABLE"
    },
    {
      "name": "firstName",
      "type": "STRING",
      "mode": "NULLABLE"
    },
    {
      "name": "lastName",
      "type": "STRING",
      "mode": "NULLABLE"
    },
    {
      "name": "email",
      "type": "STRING",
      "mode": "NULLABLE"
    },
    {
      "name": "isArchived",
      "type": "BOOLEAN",
      "mode": "NULLABLE"
    },
    {
      "name": "teamId",
      "type": "INTEGER",
      "mode": "NULLABLE"
    },
    {
      "name": "holidaysGroupId",
      "type": "INTEGER",
      "mode": "NULLABLE"
    },
    {
      "name": "harvestId",
      "type": "INTEGER",
      "mode": "NULLABLE"
    },
    {
      "name": "managers",
      "type": "RECORD",
      "mode": "REPEATED",
      "fields": [
        {
        "name": "id",
        "type": "INTEGER",
        "mode": "NULLABLE"
        }
      ]
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
    }
  ]
  EOF


  labels = {
    env = var.env
  }

  deletion_protection = true

  encryption_configuration {
    kms_key_name = google_kms_crypto_key.bigquery_key.id
  }
}


# --------------------------placeholders table --------------------------------\
resource "google_bigquery_table" "runn_placeholders" {
  dataset_id = google_bigquery_dataset.runn_raw.dataset_id
  table_id   = "placeholders"

  time_partitioning {
    type = "DAY"
  }

  schema = <<EOF
  [
    {
      "name": "id",
      "type": "INTEGER",
      "mode": "NULLABLE"
    },
    {
      "name": "firstName",
      "type": "STRING",
      "mode": "NULLABLE"
    },
    {
      "name": "lastName",
      "type": "STRING",
      "mode": "NULLABLE"
    },
    {
      "name": "isArchived",
      "type": "BOOLEAN",
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
    }
  ]
  EOF


  labels = {
    env = var.env
  }

  deletion_protection = true

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

  schema = <<EOF
  [
    {
      "name": "id",
      "type": "INTEGER",
      "mode": "NULLABLE"
    },
    {
      "name": "name",
      "type": "STRING",
      "mode": "NULLABLE"
    },
    {
      "name": "isTemplate",
      "type": "BOOLEAN",
      "mode": "NULLABLE"
    },
    {
      "name": "isArchived",
      "type": "BOOLEAN",
      "mode": "NULLABLE"
    },
    {
      "name": "isConfirmed",
      "type": "BOOLEAN",
      "mode": "NULLABLE"
    },
    {
      "name": "pricingModel",
      "type": "STRING",
      "mode": "NULLABLE"
    },
    {
      "name": "rateType",
      "type": "STRING",
      "mode": "NULLABLE"
    },
    {
      "name": "teamId",
      "type": "INTEGER",
      "mode": "NULLABLE"
    },
    {
      "name": "budget",
      "type": "FLOAT",
      "mode": "NULLABLE"
    },
    {
      "name": "expensesBudget",
      "type": "FLOAT",
      "mode": "NULLABLE"
    },
    {
      "name": "clientId",
      "type": "INTEGER",
      "mode": "NULLABLE"
    },
    {
      "name": "rateCardId",
      "type": "INTEGER",
      "mode": "NULLABLE"
    },
    {
      "name": "managerIds",
      "type": "INTEGER",
      "mode": "REPEATED"
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
      "name": "harvestId",
      "type": "STRING",
      "mode": "NULLABLE"
    },
    {
      "name": "externalId",
      "type": "STRING",
      "mode": "NULLABLE"
    },
    {
      "name": "jobNumber",
      "type": "STRING",
      "mode": "NULLABLE"
    },
    {
      "name": "projectType",
      "type": "STRING",
      "mode": "NULLABLE"
    },
    {
      "name": "tags",
      "type": "RECORD",
      "mode": "REPEATED",
      "fields": [
        {
          "name": "id",
          "type": "INTEGER",
          "mode": "NULLABLE"
        },
        {
          "name": "name",
          "type": "STRING",
          "mode": "NULLABLE"
        }
      ]
    }
  ]
  EOF
 

  labels = {
    env = var.env
  }

  deletion_protection = true

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

  deletion_protection = true

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
      "name": "holidayId",
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
      "name": "minutesPerDay",
      "type": "INTEGER",
      "mode": "NULLABLE"
    },
    {
      "name": "note",
      "type": "STRING",
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

  deletion_protection = true

  encryption_configuration {
    kms_key_name = google_kms_crypto_key.bigquery_key.id
  }
}

# --------------------------public_holidays split by day table --------------------------------\
resource "google_bigquery_table" "runn_public_holidays_split_by_day" {
  dataset_id = google_bigquery_dataset.runn_raw.dataset_id
  table_id   = "public_holidays_split_by_day"

  time_partitioning {
    type = "DAY"
  }

  labels = {
    env = var.env
  }

  deletion_protection = true

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

  schema = <<EOF
  [
    {
      "name": "id",
      "type": "INTEGER",
      "mode": "NULLABLE"
    },
    {
      "name": "name",
      "type": "STRING",
      "mode": "NULLABLE"
    },
    {
      "name": "description",
      "type": "STRING",
      "mode": "NULLABLE"
    },
    {
      "name": "isArchived",
      "type": "BOOLEAN",
      "mode": "NULLABLE"
    },
    {
      "name": "isBlendedRateCard",
      "type": "BOOLEAN",
      "mode": "NULLABLE"
    },
    {
      "name": "blendedRate",
      "type": "FLOAT",
      "mode": "NULLABLE"
    },
    {
      "name": "rateType",
      "type": "STRING",
      "mode": "NULLABLE"
    },
    {
      "name": "rates",
      "type": "RECORD",
      "mode": "REPEATED",
      "fields": [
        {
          "name": "rateDaily",
          "type": "FLOAT",
          "mode": "NULLABLE"
        },
        {
          "name": "rateHourly",
          "type": "FLOAT",
          "mode": "NULLABLE"
        },
        {
          "name": "role",
          "type": "RECORD",
          "mode": "NULLABLE",
          "fields": [
            {
              "name": "id",
              "type": "INTEGER",
              "mode": "NULLABLE"
            },
            {
              "name": "name",
              "type": "STRING",
              "mode": "NULLABLE"
            }
          ]
        }
      ]
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
    }
  ]
  EOF

  labels = {
    env = var.env
  }

  deletion_protection = true

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

  schema = <<EOF
  [
    {
      "name": "id",
      "type": "INTEGER",
      "mode": "NULLABLE"
    },
    {
      "name": "name",
      "type": "STRING",
      "mode": "NULLABLE"
    },
    {
      "name": "isArchived",
      "type": "BOOLEAN",
      "mode": "NULLABLE"
    },
    {
      "name": "defaultHourCost",
      "type": "FLOAT",
      "mode": "NULLABLE"
    },
    {
      "name": "standardRate",
      "type": "FLOAT",
      "mode": "NULLABLE"
    },
    {
      "name": "personIds",
      "type": "INTEGER",
      "mode": "REPEATED"
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
    }
  ]
  EOF

  labels = {
    env = var.env
  }

  deletion_protection = true

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

  schema = <<EOF
  [
    {
      "name": "id",
      "type": "INTEGER",
      "mode": "NULLABLE"
    },
    {
      "name": "name",
      "type": "STRING",
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
    }
  ]
  EOF

  labels = {
    env = var.env
  }

  deletion_protection = true

  encryption_configuration {
    kms_key_name = google_kms_crypto_key.bigquery_key.id
  }
}


# --------------------------time-offs-holidays table --------------------------------\
resource "google_bigquery_table" "runn_time_offs_holidays" {
  dataset_id = google_bigquery_dataset.runn_raw.dataset_id
  table_id   = "time_offs_holidays"

  time_partitioning {
    type = "DAY"
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
      "name": "note",
      "type": "STRING",
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
      "name": "minutesPerDay",
      "type": "INTEGER",
      "mode": "NULLABLE"
    },
    {
      "name": "holidayId",
      "type": "INTEGER",
      "mode": "NULLABLE"
    }
  ]
  EOF

  labels = {
    env = var.env
  }

  deletion_protection = true

  encryption_configuration {
    kms_key_name = google_kms_crypto_key.bigquery_key.id
  }
}

# --------------------------time-offs-leave table --------------------------------\
resource "google_bigquery_table" "runn_time_offs_leave" {
  dataset_id = google_bigquery_dataset.runn_raw.dataset_id
  table_id   = "time_offs_leave"

  time_partitioning {
    type = "DAY"
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
      "name": "note",
      "type": "STRING",
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
      "name": "minutesPerDay",
      "type": "INTEGER",
      "mode": "NULLABLE"
    }
  ]
  EOF

  labels = {
    env = var.env
  }

  deletion_protection = true

  encryption_configuration {
    kms_key_name = google_kms_crypto_key.bigquery_key.id
  }
}


# --------------------------time-offs-rostered-days-off table --------------------------------\
resource "google_bigquery_table" "runn_time_offs_rostered_days_off" {
  dataset_id = google_bigquery_dataset.runn_raw.dataset_id
  table_id   = "time_offs_rostered_days_off"

  time_partitioning {
    type = "DAY"
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
      "name": "note",
      "type": "STRING",
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
      "name": "minutesPerDay",
      "type": "INTEGER",
      "mode": "NULLABLE"
    }
  ]
  EOF

  labels = {
    env = var.env
  }

  deletion_protection = true

  encryption_configuration {
    kms_key_name = google_kms_crypto_key.bigquery_key.id
  }
}



# ---------------------------Per project rates --------------------------------\
resource "google_bigquery_table" "runn_per_project_rates" {
  dataset_id = google_bigquery_dataset.runn_raw.dataset_id
  table_id   = "per_project_rates"

  time_partitioning {
    type = "DAY"
  }

  schema = <<EOF
  [
    {
      "name": "id",
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
      "name": "rate",
      "type": "FLOAT",
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
    }
  ]
  EOF

  labels = {
    env = var.env
  }

  deletion_protection = true

  encryption_configuration {
    kms_key_name = google_kms_crypto_key.bigquery_key.id
  }
}

# ---------------------------Per project Budget roles --------------------------------\
resource "google_bigquery_table" "runn_per_project_budget_roles" {
  dataset_id = google_bigquery_dataset.runn_raw.dataset_id
  table_id   = "per_project_budget_roles"

  time_partitioning {
    type = "DAY"
  }

  schema = <<EOF
  [
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
      "name": "estimatedMinutes",
      "type": "INTEGER",
      "mode": "NULLABLE"
    },
    {
      "name": "estimatedBudget",
      "type": "FLOAT",
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
    }
  ]
  EOF

  labels = {
    env = var.env
  }

  deletion_protection = true

  encryption_configuration {
    kms_key_name = google_kms_crypto_key.bigquery_key.id
  }
}