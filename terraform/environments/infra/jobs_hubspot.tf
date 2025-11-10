# Cloud Run job automation for HubSpot pipelines

resource "google_cloud_scheduler_job" "hubspot_companies" {
  name      = "hubspot-companies-pipe-scheduler-trigger"
  schedule  = "0 2 * * * "
  time_zone = "Europe/London"
  region    = var.region

  retry_config {
    retry_count = 0
  }

  http_target {
    http_method = "POST"
    uri         = "https://${var.region}-run.googleapis.com/apis/run.googleapis.com/v1/namespaces/${var.project}/jobs/hubspot-companies-pipe:run"

    oauth_token {
      service_account_email = var.serviceaccount
      scope                 = "https://www.googleapis.com/auth/cloud-platform"
    }
  }
}

resource "google_cloud_scheduler_job" "hubspot_deals" {
  name      = "hubspot-deals-pipe-scheduler-trigger"
  schedule  = "0 2 * * * "
  time_zone = "Europe/London"
  region    = var.region

  retry_config {
    retry_count = 0
  }

  http_target {
    http_method = "POST"
    uri         = "https://${var.region}-run.googleapis.com/apis/run.googleapis.com/v1/namespaces/${var.project}/jobs/hubspot-deals-pipe:run"

    oauth_token {
      service_account_email = var.serviceaccount
      scope                 = "https://www.googleapis.com/auth/cloud-platform"
    }
  }
}

resource "google_cloud_scheduler_job" "hubspot_deals_stages" {
  name      = "hubspot-deals-stages-pipe-scheduler-trigger"
  schedule  = "0 2 * * * "
  time_zone = "Europe/London"
  region    = var.region

  retry_config {
    retry_count = 0
  }

  http_target {
    http_method = "POST"
    uri         = "https://${var.region}-run.googleapis.com/apis/run.googleapis.com/v1/namespaces/${var.project}/jobs/hubspot-deals-stages-pipe:run"

    oauth_token {
      service_account_email = var.serviceaccount
      scope                 = "https://www.googleapis.com/auth/cloud-platform"
    }
  }
}

resource "google_cloud_scheduler_job" "hubspot_pipelines" {
  name      = "hubspot-pipelines-pipe-scheduler-trigger"
  schedule  = "0 2 * * * "
  time_zone = "Europe/London"
  region    = var.region

  retry_config {
    retry_count = 0
  }

  http_target {
    http_method = "POST"
    uri         = "https://${var.region}-run.googleapis.com/apis/run.googleapis.com/v1/namespaces/${var.project}/jobs/hubspot-pipelines-pipe:run"

    oauth_token {
      service_account_email = var.serviceaccount
      scope                 = "https://www.googleapis.com/auth/cloud-platform"
    }
  }
}

resource "google_cloud_run_v2_job" "hubspot_companies" {
  name     = "hubspot-companies-pipe"
  location = var.region

  deletion_protection = false

  template {
    task_count = 1
    template {
      service_account = var.pipelines_serviceaccount
      timeout         = var.job_timeout

      containers {
        name  = "python"
        image = data.google_artifact_registry_docker_image.hubspot_companies.self_link

        working_dir = "/app"
        command     = ["uv", "run", "python", "-m", "src.main"]
      }
    }
  }
}

resource "google_cloud_run_v2_job" "hubspot_deals" {
  name     = "hubspot-deals-pipe"
  location = var.region

  deletion_protection = false

  template {
    task_count = 1
    template {
      service_account = var.pipelines_serviceaccount
      timeout         = var.job_timeout

      containers {
        name  = "python"
        image = data.google_artifact_registry_docker_image.hubspot_deals.self_link

        working_dir = "/app"
        command     = ["uv", "run", "python", "-m", "src.main"]
      }
    }
  }
}

resource "google_cloud_run_v2_job" "hubspot_deals_stages" {
  name     = "hubspot-deals-stages-pipe"
  location = var.region

  deletion_protection = false

  template {
    task_count = 1
    template {
      service_account = var.pipelines_serviceaccount
      timeout         = var.job_timeout

      containers {
        name  = "python"
        image = data.google_artifact_registry_docker_image.hubspot_deals_stages.self_link

        working_dir = "/app"
        command     = ["uv", "run", "python", "-m", "src.main"]
      }
    }
  }
}

resource "google_cloud_run_v2_job" "hubspot_pipelines" {
  name     = "hubspot-pipelines-pipe"
  location = var.region

  deletion_protection = false

  template {
    task_count = 1
    template {
      service_account = var.pipelines_serviceaccount
      timeout         = var.job_timeout

      containers {
        name  = "python"
        image = data.google_artifact_registry_docker_image.hubspot_pipelines.self_link

        working_dir = "/app"
        command     = ["uv", "run", "python", "-m", "src.main"]
      }
    }
  }
}

data "google_artifact_registry_docker_image" "hubspot_companies" {
  location      = google_artifact_registry_repository.cloud_run_images.location
  repository_id = google_artifact_registry_repository.cloud_run_images.repository_id
  image_name    = "hubspot-companies-pipe@${docker_registry_image.hubspot_companies.sha256_digest}"
}

data "google_artifact_registry_docker_image" "hubspot_deals" {
  location      = google_artifact_registry_repository.cloud_run_images.location
  repository_id = google_artifact_registry_repository.cloud_run_images.repository_id
  image_name    = "hubspot-deals-pipe@${docker_registry_image.hubspot_deals.sha256_digest}"
}

data "google_artifact_registry_docker_image" "hubspot_deals_stages" {
  location      = google_artifact_registry_repository.cloud_run_images.location
  repository_id = google_artifact_registry_repository.cloud_run_images.repository_id
  image_name    = "hubspot-deals-stages-pipe@${docker_registry_image.hubspot_deals_stages.sha256_digest}"
}

data "google_artifact_registry_docker_image" "hubspot_pipelines" {
  location      = google_artifact_registry_repository.cloud_run_images.location
  repository_id = google_artifact_registry_repository.cloud_run_images.repository_id
  image_name    = "hubspot-pipelines-pipe@${docker_registry_image.hubspot_pipelines.sha256_digest}"
}

resource "docker_registry_image" "hubspot_companies" {
  name          = docker_image.hubspot_companies.name
  keep_remotely = true

  triggers = {
    image_sha = docker_image.hubspot_companies.repo_digest
  }
}

resource "docker_registry_image" "hubspot_deals" {
  name          = docker_image.hubspot_deals.name
  keep_remotely = true

  triggers = {
    image_sha = docker_image.hubspot_deals.repo_digest
  }
}

resource "docker_registry_image" "hubspot_deals_stages" {
  name          = docker_image.hubspot_deals_stages.name
  keep_remotely = true

  triggers = {
    image_sha = docker_image.hubspot_deals_stages.repo_digest
  }
}

resource "docker_registry_image" "hubspot_pipelines" {
  name          = docker_image.hubspot_pipelines.name
  keep_remotely = true

  triggers = {
    image_sha = docker_image.hubspot_pipelines.repo_digest
  }
}

locals {
  hubspot_companies = {
    context_dir     = "${path.root}/../../../cloud_run_jobs/hubspot/companies"
    dockerfile_path = "${path.root}/../../../docker-images/jobs.Dockerfile"
  }

  hubspot_deals = {
    context_dir     = "${path.root}/../../../cloud_run_jobs/hubspot/deals"
    dockerfile_path = "${path.root}/../../../docker-images/jobs.Dockerfile"
  }

  hubspot_deals_stages = {
    context_dir     = "${path.root}/../../../cloud_run_jobs/hubspot/deals_stages"
    dockerfile_path = "${path.root}/../../../docker-images/jobs.Dockerfile"
  }

  hubspot_pipelines = {
    context_dir     = "${path.root}/../../../cloud_run_jobs/hubspot/pipelines"
    dockerfile_path = "${path.root}/../../../docker-images/jobs.Dockerfile"
  }
}

resource "docker_image" "hubspot_companies" {
  name = "${var.region}-docker.pkg.dev/${var.project}/${google_artifact_registry_repository.cloud_run_images.repository_id}/hubspot-companies-pipe"
  build {
    context    = local.hubspot_companies.context_dir
    dockerfile = local.hubspot_companies.dockerfile_path
  }

  force_remove = true

  triggers = {
    dir_sha1 = sha1(join("", [for f in fileset(local.hubspot_companies.context_dir, "**") : filesha1("${local.hubspot_companies.context_dir}/${f}")]))
  }
}

resource "docker_image" "hubspot_deals" {
  name = "${var.region}-docker.pkg.dev/${var.project}/${google_artifact_registry_repository.cloud_run_images.repository_id}/hubspot-deals-pipe"
  build {
    context    = local.hubspot_deals.context_dir
    dockerfile = local.hubspot_deals.dockerfile_path
  }

  force_remove = true

  triggers = {
    dir_sha1 = sha1(join("", [for f in fileset(local.hubspot_deals.context_dir, "**") : filesha1("${local.hubspot_deals.context_dir}/${f}")]))
  }
}

resource "docker_image" "hubspot_deals_stages" {
  name = "${var.region}-docker.pkg.dev/${var.project}/${google_artifact_registry_repository.cloud_run_images.repository_id}/hubspot-deals-stages-pipe"
  build {
    context    = local.hubspot_deals_stages.context_dir
    dockerfile = local.hubspot_deals_stages.dockerfile_path
  }

  force_remove = true

  triggers = {
    dir_sha1 = sha1(join("", [for f in fileset(local.hubspot_deals_stages.context_dir, "**") : filesha1("${local.hubspot_deals_stages.context_dir}/${f}")]))
  }
}

resource "docker_image" "hubspot_pipelines" {
  name = "${var.region}-docker.pkg.dev/${var.project}/${google_artifact_registry_repository.cloud_run_images.repository_id}/hubspot-pipelines-pipe"
  build {
    context    = local.hubspot_pipelines.context_dir
    dockerfile = local.hubspot_pipelines.dockerfile_path
  }

  force_remove = true

  triggers = {
    dir_sha1 = sha1(join("", [for f in fileset(local.hubspot_pipelines.context_dir, "**") : filesha1("${local.hubspot_pipelines.context_dir}/${f}")]))
  }
}
