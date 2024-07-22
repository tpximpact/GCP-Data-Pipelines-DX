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
    resource   = google_pubsub_topic.cloud_function_trigger_hot.id
  }

  environment_variables = {
    "DATASET_ID"           = google_bigquery_dataset.runn_raw.dataset_id
    "TABLE_NAME"           = google_bigquery_table.runn_assignments.table_id
    "TABLE_LOCATION"       = google_bigquery_dataset.runn_raw.location
    "GOOGLE_CLOUD_PROJECT" = var.project

  }
}


# --------------------------actuals--------------------------------\
# Generates an archive of the source code compressed as a .zip file.
data "archive_file" "runn_actuals" {
  type        = "zip"
  source_dir  = "../../../cloud_functions/runn/actuals"
  output_path = "/tmp/runn_actuals.zip"
}

# Add source code zip to the Cloud Function's bucket
resource "google_storage_bucket_object" "runn_actuals" {
  source       = data.archive_file.runn_actuals.output_path
  content_type = "application/zip"

  # Append to the MD5 checksum of the files's content
  # to force the zip to be updated as soon as a change occurs
  name   = "cloud_function-${data.archive_file.runn_actuals.output_md5}.zip"
  bucket = data.google_storage_bucket.function_bucket.name
}

resource "google_cloudfunctions_function" "runn_actuals" {
  name                = "runn_actuals_pipe"
  runtime             = "python312" # of course changeable
  available_memory_mb = 1024
  timeout             = 540
  # Get the source code of the cloud function as a Zip compression
  source_archive_bucket = data.google_storage_bucket.function_bucket.name
  source_archive_object = google_storage_bucket_object.runn_actuals.name

  # Must match the function name in the cloud function `main.py` source code
  entry_point                  = "main"
  https_trigger_security_level = "SECURE_ALWAYS"
  event_trigger {
    event_type = "providers/cloud.pubsub/eventTypes/topic.publish"
    resource   = google_pubsub_topic.cloud_function_trigger_hot_15.id
  }

  environment_variables = {
    "DATASET_ID"           = google_bigquery_dataset.runn_raw.dataset_id
    "TABLE_NAME"           = google_bigquery_table.runn_actuals.table_id
    "TABLE_LOCATION"       = google_bigquery_dataset.runn_raw.location
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
