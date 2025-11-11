data "google_storage_bucket" "function_bucket" {
    name     = "${var.project}-function"
}

resource "google_storage_bucket" "function_bucket" {
    name = data.google_storage_bucket.function_bucket.name
    location = var.region

    public_access_prevention = "enforced"
}

data "google_storage_bucket" "job_bucket" {
    name     = "${var.project}-job"
}

resource "google_storage_bucket" "job_bucket" {
    name = data.google_storage_bucket.job_bucket.name
    location = var.region

    public_access_prevention = "enforced"
}



