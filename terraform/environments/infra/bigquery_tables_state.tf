resource "google_bigquery_table" "process_state" {
  dataset_id = google_bigquery_dataset.state_tables.dataset_id
  table_id   = "process_state"

  schema = <<EOF
  [
    {
      "name": "id",
      "type": "STRING"
    },
    {
      "name": "next_page",
      "type": "STRING",
      "mode": "NULLABLE"
    },
    {
      "name": "batch_start_time",
      "type": "TIMESTAMP",
      "mode": "NULLABLE"
    },
    {
      "name": "updated_since",
      "type": "TIMESTAMP",
      "mode": "NULLABLE"
    },
    {
      "name": "last_processed_time",
      "type": "TIMESTAMP",
      "mode": "NULLABLE"
    },
    {
      "name": "page_number",
      "type": "INTEGER",
      "mode": "NULLABLE"
    }
  ]
  EOF


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

