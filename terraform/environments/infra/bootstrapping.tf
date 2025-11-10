

# Bootstrapping roles
# You need to manually ensure the following roles are given to "var.deploy_serviceaccount" service account
# BEFORE running terraform apply.

# They are here for reference.
resource "google_project_iam_member" "storage_admin" {
  project = var.project
  role = "roles/storage.admin"
  member = "serviceAccount:${var.deploy_serviceaccount}"
}

resource "google_storage_bucket_iam_member" "job_bucket_admin" {
  bucket = google_storage_bucket.job_bucket.name
  member = "serviceAccount:${var.deploy_serviceaccount}"
  role = "roles/storage.admin"
}

resource "google_storage_bucket_iam_member" "function_bucket_admin" {
  bucket = google_storage_bucket.function_bucket.name
  member = "serviceAccount:${var.deploy_serviceaccount}"
  role = "roles/storage.admin"
}

resource "google_project_iam_member" "secretmanager_admin" {
  project = var.project
  role = "roles/secretmanager.admin"
  member = "serviceAccount:${var.deploy_serviceaccount}"
}

resource "google_project_iam_member" "cloudkms_admin" {
  project = var.project
  role = "roles/cloudkms.admin"
  member = "serviceAccount:${var.deploy_serviceaccount}"
}

resource "google_project_iam_member" "pubsub_admin" {
  project = var.project
  role = "roles/pubsub.admin"
  member = "serviceAccount:${var.deploy_serviceaccount}"
}

resource "google_project_iam_member" "cloudscheduler_admin" {
  project = var.project
  role = "roles/cloudscheduler.admin"
  member = "serviceAccount:${var.deploy_serviceaccount}"
}

resource "google_project_iam_member" "cloudrun_admin" {
  project = var.project
  role = "roles/run.admin"
  member = "serviceAccount:${var.deploy_serviceaccount}"
}

resource "google_project_iam_member" "iam_admin" {
  project = var.project
  role = "roles/resourcemanager.projectIamAdmin"
  member = "serviceAccount:${var.deploy_serviceaccount}"
}

resource "google_project_iam_member" "bigquery_admin" {
  project = var.project
  role = "roles/bigquery.admin"
  member = "serviceAccount:${var.deploy_serviceaccount}"
}

resource "google_project_iam_member" "functions_admin" {
  project = var.project
  role = "roles/cloudfunctions.admin"
  member = "serviceAccount:${var.deploy_serviceaccount}"
}

resource "google_project_iam_member" "artifactregistry_admin" {
  project = var.project
  role = "roles/artifactregistry.admin"
  member = "serviceAccount:${var.deploy_serviceaccount}"
}

resource "google_project_iam_member" "iam_serviceaccounttokencreator" {
  project = var.project
  role = "roles/iam.serviceAccountTokenCreator"
  member = "serviceAccount:${var.deploy_serviceaccount}"
}

resource "google_project_iam_member" "iam_serviceaccountuser" {
  project = var.project
  role = "roles/iam.serviceAccountUser"
  member = "serviceAccount:${var.deploy_serviceaccount}"
}
