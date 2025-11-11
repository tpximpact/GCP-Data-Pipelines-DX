data "google_kms_key_ring" "dashboards_keyring" {
  name     = "dashboards_keyring"
  location = "europe-west2"
}

resource "google_kms_crypto_key" "bigquery_key" {
  name     = "bigquery_key"
  key_ring = data.google_kms_key_ring.dashboards_keyring.id
}
resource "google_kms_crypto_key_iam_member" "bigquery_key_encrypt_decrypt" {
  crypto_key_id = google_kms_crypto_key.bigquery_key.id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = "serviceAccount:bq-${data.google_project.project_number.number}@bigquery-encryption.iam.gserviceaccount.com"

}
