data "google_storage_bucket" "function_bucket" {
    name     = "${var.project}-function"
}

data "google_storage_bucket" "job_bucket" {
    name     = "${var.project}-job"
}
