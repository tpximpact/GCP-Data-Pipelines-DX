# --------------------------runn contracts--------------------------------\
# Generates an archive of the source code compressed as a .zip file.
data "archive_file" "runn_contracts" {
  type        = "zip"
  source_dir  = "../../../cloud_functions/runn/contracts"
  output_path = "/tmp/runn_contracts.zip"
}

# Add source code zip to the Cloud Function's bucket
resource "google_storage_bucket_object" "runn_contracts" {
  source       = data.archive_file.runn_contracts.output_path
  content_type = "application/zip"

  # Append to the MD5 checksum of the files content
  # to force the zip to be updated as soon as a change occurs
  name   = "cloud_function-${data.archive_file.runn_contracts.output_md5}.zip"
  bucket = data.google_storage_bucket.function_bucket.name
}

resource "google_cloudfunctions_function" "runn_contracts" {
  name                = "runn_contracts_pipe"
  runtime             = "python312" # of course changeable
  available_memory_mb = 512
  timeout             = 540
  # Get the source code of the cloud function as a Zip compression
  source_archive_bucket = data.google_storage_bucket.function_bucket.name
  source_archive_object = google_storage_bucket_object.runn_contracts.name

  # Must match the function name in the cloud function `main.py` source code
  entry_point                  = "main"
  https_trigger_security_level = "SECURE_ALWAYS"
  event_trigger {
    event_type = "providers/cloud.pubsub/eventTypes/topic.publish"
    resource   = google_pubsub_topic.cloud_function_trigger_tester.id
  }

  environment_variables = {
    "DATASET_ID"           = google_bigquery_dataset.runn_raw.dataset_id
    "TABLE_NAME"           = google_bigquery_table.runn_contracts.table_id
    "TABLE_LOCATION"       = google_bigquery_dataset.runn_raw.location
    "STATE_TABLE_NAME"     = "${google_bigquery_dataset.state_tables.dataset_id}.${google_bigquery_table.process_state.table_id}"
    "GOOGLE_CLOUD_PROJECT" = var.project

  }
}

# --------------------------runn people--------------------------------\
# Generates an archive of the source code compressed as a .zip file.
data "archive_file" "runn_people" {
  type        = "zip"
  source_dir  = "../../../cloud_functions/runn/people"
  output_path = "/tmp/runn_people.zip"
}

# Add source code zip to the Cloud Function's bucket
resource "google_storage_bucket_object" "runn_people" {
  source       = data.archive_file.runn_people.output_path
  content_type = "application/zip"

  # Append to the MD5 checksum of the files's content
  # to force the zip to be updated as soon as a change occurs
  name   = "cloud_function-${data.archive_file.runn_people.output_md5}.zip"
  bucket = data.google_storage_bucket.function_bucket.name
}

resource "google_cloudfunctions_function" "runn_people" {
  name                = "runn_people_pipe"
  runtime             = "python312" # of course changeable
  available_memory_mb = 512
  timeout             = 540
  # Get the source code of the cloud function as a Zip compression
  source_archive_bucket = data.google_storage_bucket.function_bucket.name
  source_archive_object = google_storage_bucket_object.runn_people.name

  # Must match the function name in the cloud function `main.py` source code
  entry_point                  = "main"
  https_trigger_security_level = "SECURE_ALWAYS"
  event_trigger {
    event_type = "providers/cloud.pubsub/eventTypes/topic.publish"
    resource   = google_pubsub_topic.cloud_function_trigger_cold.id
  }
 
  environment_variables = {
    "DATASET_ID"           = google_bigquery_dataset.runn_raw.dataset_id
    "TABLE_NAME"           = google_bigquery_table.runn_people.table_id
    "TABLE_LOCATION"       = google_bigquery_dataset.runn_raw.location
    "GOOGLE_CLOUD_PROJECT" = var.project

  }
}

# --------------------------projects--------------------------------\
# Generates an archive of the source code compressed as a .zip file.
data "archive_file" "runn_projects" {
  type        = "zip"
  source_dir  = "../../../cloud_functions/runn/projects"
  output_path = "/tmp/runn_projects.zip"
}
# 
# # Add source code zip to the Cloud Function's bucket
resource "google_storage_bucket_object" "runn_projects" {
  source       = data.archive_file.runn_projects.output_path
  content_type = "application/zip"

  # Append to the MD5 checksum of the files's content
  # to force the zip to be updated as soon as a change occurs
  name   = "cloud_function-${data.archive_file.runn_projects.output_md5}.zip"
  bucket = data.google_storage_bucket.function_bucket.name
}

resource "google_cloudfunctions_function" "runn_projects" {
  name                = "runn_projects_pipe"
  runtime             = "python312" # of course changeable
  available_memory_mb = 512
  timeout             = 540
  # Get the source code of the cloud function as a Zip compression
  source_archive_bucket = data.google_storage_bucket.function_bucket.name
  source_archive_object = google_storage_bucket_object.runn_projects.name

  # Must match the function name in the cloud function `main.py` source code
  entry_point                  = "main"
  https_trigger_security_level = "SECURE_ALWAYS"
  event_trigger {
    event_type = "providers/cloud.pubsub/eventTypes/topic.publish"
    resource   = google_pubsub_topic.cloud_function_trigger_hot.id
  }

  environment_variables = {
      "DATASET_ID"           = google_bigquery_dataset.runn_raw.dataset_id
      "TABLE_NAME"           = google_bigquery_table.runn_projects.table_id
      "TABLE_LOCATION"       = google_bigquery_dataset.runn_raw.location
      "GOOGLE_CLOUD_PROJECT" = var.project
    }
}

# --------------------------assignments--------------------------------\
# Generates an archive of the source code compressed as a .zip file.
data "archive_file" "runn_assignments" {
  type        = "zip"
  source_dir  = "../../../cloud_functions/runn/assignments"
  output_path = "/tmp/runn_assignments.zip"
}

# Add source code zip to the Cloud Function's bucket
resource "google_storage_bucket_object" "runn_assignments" {
  source       = data.archive_file.runn_assignments.output_path
  content_type = "application/zip"

  # Append to the MD5 checksum of the files's content
  # to force the zip to be updated as soon as a change occurs
  name   = "cloud_function-${data.archive_file.runn_assignments.output_md5}.zip"
  bucket = data.google_storage_bucket.function_bucket.name
}

resource "google_cloudfunctions_function" "runn_assignments" {
  name                = "runn_assignments_pipe"
  runtime             = "python312" # of course changeable
  available_memory_mb = 512
  timeout             = 540
  # Get the source code of the cloud function as a Zip compression
  source_archive_bucket = data.google_storage_bucket.function_bucket.name
  source_archive_object = google_storage_bucket_object.runn_assignments.name

  # Must match the function name in the cloud function `main.py` source code
  entry_point                  = "main"
  https_trigger_security_level = "SECURE_ALWAYS"
  event_trigger {
    event_type = "providers/cloud.pubsub/eventTypes/topic.publish"
    resource   = google_pubsub_topic.cloud_function_trigger_hot_15.id
  }

  environment_variables = {
    "DATASET_ID"           = google_bigquery_dataset.runn_raw.dataset_id
    "TABLE_NAME"           = google_bigquery_table.runn_assignments.table_id
    "TABLE_LOCATION"       = google_bigquery_dataset.runn_raw.location
    "PROCESS_TABLE_NAME"   = google_bigquery_table.runn_assignments_process_table.table_id
    "GOOGLE_CLOUD_PROJECT" = var.project

  }
}

# --------------------------assignments new --------------------------------\
# Generates an archive of the source code compressed as a .zip file.
data "archive_file" "runn_assignments_new" {
  type        = "zip"
  source_dir  = "../../../cloud_functions/runn/assignments_new"
  output_path = "/tmp/runn_assignments_new.zip"
}

# Add source code zip to the Cloud Function's bucket
resource "google_storage_bucket_object" "runn_assignments_new" {
  source       = data.archive_file.runn_assignments_new.output_path
  content_type = "application/zip"

  # Append to the MD5 checksum of the files's content
  # to force the zip to be updated as soon as a change occurs
  name   = "cloud_function-${data.archive_file.runn_assignments_new.output_md5}.zip"
  bucket = data.google_storage_bucket.function_bucket.name
}

resource "google_cloudfunctions_function" "runn_assignments_new" {
  name                = "runn_assignments_new_pipe"
  runtime             = "python312" # of course changeable
  available_memory_mb = 512
  timeout             = 540
  # Get the source code of the cloud function as a Zip compression
  source_archive_bucket = data.google_storage_bucket.function_bucket.name
  source_archive_object = google_storage_bucket_object.runn_assignments_new.name

  # Must match the function name in the cloud function `main.py` source code
  entry_point                  = "main"
  https_trigger_security_level = "SECURE_ALWAYS"
  event_trigger {
    event_type = "providers/cloud.pubsub/eventTypes/topic.publish"
    resource   = google_pubsub_topic.cloud_function_trigger_cold.id
  }

  environment_variables = {
    "DATASET_ID"           = google_bigquery_dataset.runn_raw.dataset_id
    "TABLE_NAME"           = google_bigquery_table.runn_assignments_new.table_id
    "TABLE_LOCATION"       = google_bigquery_dataset.runn_raw.location
    "STATE_TABLE_NAME"     = "${google_bigquery_dataset.state_tables.dataset_id}.${google_bigquery_table.process_state.table_id}"
    "GOOGLE_CLOUD_PROJECT" = var.project

  }
}

# --------------------------assignments split by day --------------------------------\
# Generates an archive of the source code compressed as a .zip file.
data "archive_file" "runn_assignments_split_by_day" {
  type        = "zip"
  source_dir  = "../../../cloud_functions/runn/assignments_split_by_day"
  output_path = "/tmp/assignments_split_by_day.zip"
}

# Add source code zip to the Cloud Function's bucket
resource "google_storage_bucket_object" "runn_assignments_split_by_day" {
  source       = data.archive_file.runn_assignments_split_by_day.output_path
  content_type = "application/zip"

  # Append to the MD5 checksum of the files's content
  # to force the zip to be updated as soon as a change occurs
  name   = "cloud_function-${data.archive_file.runn_assignments_split_by_day.output_md5}.zip"
  bucket = data.google_storage_bucket.function_bucket.name
}

resource "google_cloudfunctions_function" "runn_assignments_split_by_day" {
  name                = "runn_assignments_split_by_day"
  runtime             = "python312" # of course changeable
  available_memory_mb = 512
  timeout             = 540
  # Get the source code of the cloud function as a Zip compression
  source_archive_bucket = data.google_storage_bucket.function_bucket.name
  source_archive_object = google_storage_bucket_object.runn_assignments_split_by_day.name

  # Must match the function name in the cloud function `main.py` source code
  entry_point                  = "main"
  https_trigger_security_level = "SECURE_ALWAYS"
  event_trigger {
    event_type = "providers/cloud.pubsub/eventTypes/topic.publish"
    resource   = google_pubsub_topic.cloud_function_trigger_cold.id
  }

  environment_variables = {
    "DATASET_ID"             = google_bigquery_dataset.runn_processed.dataset_id
    "DESTINATION_TABLE_NAME" = google_bigquery_table.runn_assignments_new.table_id
    "SOURCE_TABLE_NAME"      = "assignments_latest_new"
    "TABLE_LOCATION"         = google_bigquery_dataset.runn_raw.location
    "GOOGLE_CLOUD_PROJECT"   = var.project

  }
}

# -------------------------- clients --------------------------------\
# Generates an archive of the source code compressed as a .zip file.
data "archive_file" "runn_clients" {
  type        = "zip"
  source_dir  = "../../../cloud_functions/runn/clients"
  output_path = "/tmp/runn_clients.zip"
}

# Add source code zip to the Cloud Function's bucket
resource "google_storage_bucket_object" "runn_clients" {
  source       = data.archive_file.runn_clients.output_path
  content_type = "application/zip"

  # Append to the MD5 checksum of the files's content
  # to force the zip to be updated as soon as a change occurs
  name   = "cloud_function-${data.archive_file.runn_clients.output_md5}.zip"
  bucket = data.google_storage_bucket.function_bucket.name
}

resource "google_cloudfunctions_function" "runn_clients" {
  name                = "runn_clients_pipe"
  runtime             = "python312" # of course changeable
  available_memory_mb = 512
  timeout             = 540
  # Get the source code of the cloud function as a Zip compression
  source_archive_bucket = data.google_storage_bucket.function_bucket.name
  source_archive_object = google_storage_bucket_object.runn_clients.name

  # Must match the function name in the cloud function `main.py` source code
  entry_point                  = "main"
  https_trigger_security_level = "SECURE_ALWAYS"
  event_trigger {
    event_type = "providers/cloud.pubsub/eventTypes/topic.publish"
    resource   = google_pubsub_topic.cloud_function_trigger_cold.id
  }

  environment_variables = {
    "DATASET_ID"           = google_bigquery_dataset.runn_raw.dataset_id
    "TABLE_NAME"           = google_bigquery_table.runn_clients.table_id
    "TABLE_LOCATION"       = google_bigquery_dataset.runn_raw.location
    "STATE_TABLE_NAME"     = "${google_bigquery_dataset.state_tables.dataset_id}.${google_bigquery_table.process_state.table_id}"
    "GOOGLE_CLOUD_PROJECT" = var.project

  }
}

# --------------------------public_holidays--------------------------------\
# Generates an archive of the source code compressed as a .zip file.
data "archive_file" "runn_public_holidays" {
  type        = "zip"
  source_dir  = "../../../cloud_functions/runn/public_holidays"
  output_path = "/tmp/public_holidays.zip"
}

# Add source code zip to the Cloud Function's bucket
resource "google_storage_bucket_object" "runn_public_holidays" {
  source       = data.archive_file.runn_public_holidays.output_path
  content_type = "application/zip"

  # Append to the MD5 checksum of the files content
  # to force the zip to be updated as soon as a change occurs
  name   = "cloud_function-${data.archive_file.runn_public_holidays.output_md5}.zip"
  bucket = data.google_storage_bucket.function_bucket.name
}

resource "google_cloudfunctions_function" "runn_public_holidays" {
  name                = "runn_public_holidays_pipe"
  runtime             = "python312" # of course changeable
  available_memory_mb = 512
  timeout             = 540
  # Get the source code of the cloud function as a Zip compression
  source_archive_bucket = data.google_storage_bucket.function_bucket.name
  source_archive_object = google_storage_bucket_object.runn_public_holidays.name

  # Must match the function name in the cloud function `main.py` source code
  entry_point                  = "main"
  https_trigger_security_level = "SECURE_ALWAYS"

  event_trigger {
    event_type = "providers/cloud.pubsub/eventTypes/topic.publish"
    resource   = google_pubsub_topic.cloud_function_trigger_hot_15.id
  }

  environment_variables = {
    "DATASET_ID"           = google_bigquery_dataset.runn_raw.dataset_id
    "TABLE_NAME"           = google_bigquery_table.runn_public_holidays.table_id
    "TABLE_LOCATION"       = google_bigquery_dataset.runn_raw.location
    "STATE_TABLE_NAME"     = "${google_bigquery_dataset.state_tables.dataset_id}.${google_bigquery_table.process_state.table_id}"
    "GOOGLE_CLOUD_PROJECT" = var.project

  }
}

# --------------------------teams--------------------------------\
# Generates an archive of the source code compressed as a .zip file.
data "archive_file" "runn_teams" {
  type        = "zip"
  source_dir  = "../../../cloud_functions/runn/teams"
  output_path = "/tmp/runn_teams.zip"
}

# Add source code zip to the Cloud Function's bucket
resource "google_storage_bucket_object" "runn_teams" {
  source       = data.archive_file.runn_teams.output_path
  content_type = "application/zip"

  # Append to the MD5 checksum of the files's content
  # to force the zip to be updated as soon as a change occurs
  name   = "cloud_function-${data.archive_file.runn_teams.output_md5}.zip"
  bucket = data.google_storage_bucket.function_bucket.name
}

resource "google_cloudfunctions_function" "runn_teams" {
  name                = "runn_teams_pipe"
  runtime             = "python312" # of course changeable
  available_memory_mb = 512
  timeout             = 540
  # Get the source code of the cloud function as a Zip compression
  source_archive_bucket = data.google_storage_bucket.function_bucket.name
  source_archive_object = google_storage_bucket_object.runn_teams.name

  # Must match the function name in the cloud function `main.py` source code
  entry_point                  = "main"
  https_trigger_security_level = "SECURE_ALWAYS"
  event_trigger {
    event_type = "providers/cloud.pubsub/eventTypes/topic.publish"
    resource   = google_pubsub_topic.cloud_function_trigger_cold.id
  }

  environment_variables = {
    "DATASET_ID"           = google_bigquery_dataset.runn_raw.dataset_id
    "TABLE_NAME"           = google_bigquery_table.runn_teams.table_id
    "TABLE_LOCATION"       = google_bigquery_dataset.runn_raw.location
    "GOOGLE_CLOUD_PROJECT" = var.project

  }
}

# --------------------------rate_cards--------------------------------\
# Generates an archive of the source code compressed as a .zip file.
data "archive_file" "runn_rate_cards" {
  type        = "zip"
  source_dir  = "../../../cloud_functions/runn/rate_cards"
  output_path = "/tmp/rate_cards.zip"
}

# Add source code zip to the Cloud Function's bucket
resource "google_storage_bucket_object" "rate_cards" {
  source       = data.archive_file.runn_rate_cards.output_path
  content_type = "application/zip"

  # Append to the MD5 checksum of the files content
  # to force the zip to be updated as soon as a change occurs
  name   = "cloud_function-${data.archive_file.runn_rate_cards.output_md5}.zip"
  bucket = data.google_storage_bucket.function_bucket.name
}

resource "google_cloudfunctions_function" "rate_cards" {
  name                = "runn_rate_cards_pipe"
  runtime             = "python312" # of course changeable
  available_memory_mb = 512
  timeout             = 540
  # Get the source code of the cloud function as a Zip compression
  source_archive_bucket = data.google_storage_bucket.function_bucket.name
  source_archive_object = google_storage_bucket_object.rate_cards.name

  # Must match the function name in the cloud function `main.py` source code
  entry_point                  = "main"
  https_trigger_security_level = "SECURE_ALWAYS"

  event_trigger {
    event_type = "providers/cloud.pubsub/eventTypes/topic.publish"
    resource   = google_pubsub_topic.cloud_function_trigger_cold.id
  }

  environment_variables = {
    "DATASET_ID"           = google_bigquery_dataset.runn_raw.dataset_id
    "TABLE_NAME"           = google_bigquery_table.runn_rate_cards.table_id
    "PROJECTS_TABLE_NAME"  = google_bigquery_table.runn_rate_project_rates.table_id
    "TABLE_LOCATION"       = google_bigquery_dataset.runn_raw.location
    "GOOGLE_CLOUD_PROJECT" = var.project

  }
}

# --------------------------roles--------------------------------\
# Generates an archive of the source code compressed as a .zip file.
data "archive_file" "runn_roles" {
  type        = "zip"
  source_dir  = "../../../cloud_functions/runn/roles"
  output_path = "/tmp/runn_roles.zip"
}

# Add source code zip to the Cloud Function's bucket
resource "google_storage_bucket_object" "runn_roles" {
  source       = data.archive_file.runn_roles.output_path
  content_type = "application/zip"

  # Append to the MD5 checksum of the files's content
  # to force the zip to be updated as soon as a change occurs
  name   = "cloud_function-${data.archive_file.runn_roles.output_md5}.zip"
  bucket = data.google_storage_bucket.function_bucket.name
}

resource "google_cloudfunctions_function" "runn_roles" {
  name                = "runn_roles_pipe"
  runtime             = "python312" # of course changeable
  available_memory_mb = 512
  timeout             = 540
  # Get the source code of the cloud function as a Zip compression
  source_archive_bucket = data.google_storage_bucket.function_bucket.name
  source_archive_object = google_storage_bucket_object.runn_roles.name

  # Must match the function name in the cloud function `main.py` source code
  entry_point                  = "main"
  https_trigger_security_level = "SECURE_ALWAYS"
  event_trigger {
    event_type = "providers/cloud.pubsub/eventTypes/topic.publish"
    resource   = google_pubsub_topic.cloud_function_trigger_cold.id
  }

  environment_variables = {
    "DATASET_ID"           = google_bigquery_dataset.runn_raw.dataset_id
    "TABLE_NAME"           = google_bigquery_table.runn_roles.table_id
    "TABLE_LOCATION"       = google_bigquery_dataset.runn_raw.location
    "GOOGLE_CLOUD_PROJECT" = var.project

  }
}

