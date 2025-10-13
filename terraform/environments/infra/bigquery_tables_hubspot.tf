resource "google_bigquery_table" "hubspot_deals" {
  dataset_id = google_bigquery_dataset.hubspot_raw.dataset_id
  table_id   = "hubspot_deals"

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
      "name": "archived",
      "type": "BOOLEAN",
      "mode": "NULLABLE"
    },
    {
      "name": "archived_at",
      "type": "TIMESTAMP",
      "mode": "NULLABLE"
    },
    {
      "name": "properties_amount",
      "type": "FLOAT",
      "mode": "NULLABLE"
    },
    {
      "name": "properties_closedate",
      "type": "TIMESTAMP",
      "mode": "NULLABLE"
    },
    {
      "name": "properties_confidence_weighting",
      "type": "FLOAT",
      "mode": "NULLABLE"
    },
    {
      "name": "properties_createdate",
      "type": "TIMESTAMP",
      "mode": "NULLABLE"
    },
    {
      "name": "properties_dealname",
      "type": "STRING",
      "mode": "NULLABLE"
    },
    {
      "name": "properties_dealstage",
      "type": "STRING",
      "mode": "NULLABLE"
    },
    {
      "name": "properties_dealtype",
      "type": "STRING",
      "mode": "NULLABLE"
    },
    {
      "name": "properties_job_number",
      "type": "STRING",
      "mode": "NULLABLE"
    },
    {
      "name": "properties_moved_to_runn_",
      "type": "STRING",
      "mode": "NULLABLE"
    },
    {
      "name": "properties_pipeline",
      "type": "STRING",
      "mode": "NULLABLE"
    },
    {
      "name": "properties_project_duration",
      "type": "FLOAT",
      "mode": "NULLABLE"
    },
    {
      "name": "properties_work_start_date",
      "type": "TIMESTAMP",
      "mode": "NULLABLE"
    },
    {
      "name": "properties_work_type_2",
      "type": "STRING",
      "mode": "NULLABLE"
    },
    {
      "name": "properties_work_type_3__dx_new_",
      "type": "STRING",
      "mode": "NULLABLE"
    },
    {
      "name": "associations_company",
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
      "name": "import_date",
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

resource "google_bigquery_table" "hubspot_deals_stages" {
  dataset_id = google_bigquery_dataset.hubspot_raw.dataset_id
  table_id   = "hubspot_deals_stages"

  time_partitioning {
    type = "DAY"
  }

  schema = <<EOF
  [
    {
      "name": "id",
      "type": "STRING",
      "mode": "NULLABLE"
    },
    {
      "name": "archived",
      "type": "BOOLEAN",
      "mode": "NULLABLE"
    },
    {
      "name": "archived_at",
      "type": "TIMESTAMP",
      "mode": "NULLABLE"
    },
    {
      "name": "label",
      "type": "STRING",
      "mode": "NULLABLE"
    },
    {
      "name": "pipeline_id",
      "type": "STRING",
      "mode": "NULLABLE"
    },
    {
      "name": "pipeline_title",
      "type": "STRING",
      "mode": "NULLABLE"
    },
    {
      "name": "metadata_isClosed",
      "type": "BOOLEAN",
      "mode": "NULLABLE"
    },
    {
      "name": "metadata_probability",
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

resource "google_bigquery_table" "hubspot_companies" {
  dataset_id = google_bigquery_dataset.hubspot_raw.dataset_id
  table_id   = "hubspot_companies"

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
      "name": "archived",
      "type": "BOOLEAN",
      "mode": "NULLABLE"
    },
    {
      "name": "archived_at",
      "type": "TIMESTAMP",
      "mode": "NULLABLE"
    },
    {
      "name": "properties_name",
      "type": "STRING",
      "mode": "NULLABLE"
    },
    {
      "name": "properties_sector_team",
      "type": "STRING",
      "mode": "NULLABLE"
    },
    {
      "name": "properties_sub_sector",
      "type": "STRING",
      "mode": "NULLABLE"
    },
    {
      "name": "unique_id",
      "type": "STRING",
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
      "name": "import_date",
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

resource "google_bigquery_table" "hubspot_pipelines" {
  dataset_id = google_bigquery_dataset.hubspot_raw.dataset_id
  table_id   = "hubspot_pipelines"

  time_partitioning {
    type = "DAY"
  }
  
  schema = <<EOF
  [
    {
      "name": "id",
      "type": "STRING",
      "mode": "NULLABLE"
    },
    {
      "name": "archived",
      "type": "BOOLEAN",
      "mode": "NULLABLE"
    },
    {
      "name": "archived_at",
      "type": "TIMESTAMP",
      "mode": "NULLABLE"
    },
    {
      "name": "label",
      "type": "STRING",
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
