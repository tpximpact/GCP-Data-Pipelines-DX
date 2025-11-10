resource "google_project_iam_member" "secret_accessor" {
  for_each = toset([
    var.frontend_serviceaccount,
    var.pipelines_serviceaccount,
  ])
  project = var.project
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${each.key}"
}
resource "google_project_iam_member" "cryptoKeyEncrypterDecrypter" {
    for_each = toset([
    var.frontend_serviceaccount,
    var.pipelines_serviceaccount,
  ])
  project = var.project
  role    = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member  = "serviceAccount:${each.key}"
}

