# Custom gcloud provider to run gcloud cli commands



resource "google_cloud_scheduler_job" "runn_actuals" {
  name = "runn-actuals-pipe-scheduler-trigger"
  # 3am schedule to offset from all other jobs (which run at 2am)
  schedule = "0 3 * * * "
  time_zone = "Europe/London"
  region = var.region


  retry_config {
    retry_count = 0
  }

  http_target {
   http_method = "POST" 
   uri = "https://europe-west2-run.googleapis.com/apis/run.googleapis.com/v1/namespaces/tpx-dx-dashboards/jobs/runn-actuals-pipe:run"
   oauth_token {
     service_account_email = var.serviceaccount
     scope = "https://www.googleapis.com/auth/cloud-platform"
   }
  }
}



resource "google_cloud_scheduler_job" "runn_project_budget_roles" {
  name = "runn-project-budget-roles-pipe-scheduler-trigger"
  # 3am schedule to offset from all other jobs (which run at 2am)
  schedule = "0 3 * * * "
  time_zone = "Europe/London"
  region = var.region


  retry_config {
    retry_count = 0
  }

  http_target {
   http_method = "POST" 
   uri = "https://europe-west2-run.googleapis.com/apis/run.googleapis.com/v1/namespaces/tpx-dx-dashboards/jobs/runn-project-budget-roles-pipe:run"
   oauth_token {
     service_account_email = var.serviceaccount
     scope = "https://www.googleapis.com/auth/cloud-platform"
   }
  }
}





resource "google_cloud_scheduler_job" "runn_per_project_rates" {
  name = "runn-per-project-rates-pipe-scheduler-trigger"
  # 3am schedule to offset from all other jobs (which run at 2am)
  schedule = "0 3 * * * "
  time_zone = "Europe/London"
  region = var.region


  retry_config {
    retry_count = 0
  }

  http_target {
   http_method = "POST" 
   uri = "https://europe-west2-run.googleapis.com/apis/run.googleapis.com/v1/namespaces/tpx-dx-dashboards/jobs/runn-per-project-rates-pipe:run"
   oauth_token {
     service_account_email = var.serviceaccount
     scope = "https://www.googleapis.com/auth/cloud-platform"
   }
  }
}





resource "google_cloud_scheduler_job" "runn_placeholders" {
  name = "runn-placeholders-pipe-scheduler-trigger"
  # 3am schedule to offset from all other jobs (which run at 2am)
  schedule = "0 3 * * * "
  time_zone = "Europe/London"
  region = var.region


  retry_config {
    retry_count = 0
  }

  http_target {
   http_method = "POST" 
   uri = "https://europe-west2-run.googleapis.com/apis/run.googleapis.com/v1/namespaces/tpx-dx-dashboards/jobs/runn-placeholders-pipe:run"
   oauth_token {
     service_account_email = var.serviceaccount
     scope = "https://www.googleapis.com/auth/cloud-platform"
   }
  }
}




resource "google_cloud_scheduler_job" "runn_project_other_expenses" {
  name = "runn-project-other-expenses-pipe-scheduler-trigger"
  # 3am schedule to offset from all other jobs (which run at 2am)
  schedule = "0 3 * * * "
  time_zone = "Europe/London"
  region = var.region


  retry_config {
    retry_count = 0
  }

  http_target {
   http_method = "POST" 
   uri = "https://europe-west2-run.googleapis.com/apis/run.googleapis.com/v1/namespaces/tpx-dx-dashboards/jobs/runn-project-other-expenses-pipe:run"
   oauth_token {
     service_account_email = var.serviceaccount
     scope = "https://www.googleapis.com/auth/cloud-platform"
   }
  }
}





resource "google_cloud_scheduler_job" "runn_time_offs_holidays" {
  name = "runn-time-offs-holidays-pipe-scheduler-trigger"
  # 3am schedule to offset from all other jobs (which run at 2am)
  schedule = "0 3 * * * "
  time_zone = "Europe/London"
  region = var.region


  retry_config {
    retry_count = 0
  }

  http_target {
   http_method = "POST" 
   uri = "https://europe-west2-run.googleapis.com/apis/run.googleapis.com/v1/namespaces/tpx-dx-dashboards/jobs/runn-time-offs-holidays-pipe:run"
   oauth_token {
     service_account_email = var.serviceaccount
     scope = "https://www.googleapis.com/auth/cloud-platform"
   }
  }
}


resource "google_cloud_scheduler_job" "runn_time_offs_leave" {
  name = "runn-time-offs-leave-pipe-scheduler-trigger"
  # 3am schedule to offset from all other jobs (which run at 2am)
  schedule = "0 3 * * * "
  time_zone = "Europe/London"
  region = var.region


  retry_config {
    retry_count = 0
  }

  http_target {
   http_method = "POST" 
   uri = "https://europe-west2-run.googleapis.com/apis/run.googleapis.com/v1/namespaces/tpx-dx-dashboards/jobs/runn-time-offs-leave-pipe:run"
   oauth_token {
     service_account_email = var.serviceaccount
     scope = "https://www.googleapis.com/auth/cloud-platform"
   }
  }
}





resource "google_cloud_scheduler_job" "runn_time_offs_rostered_days_off" {
  name = "runn-time-offs-rostered-days-off-pipe-scheduler-trigger"
  # 3am schedule to offset from all other jobs (which run at 2am)
  schedule = "0 3 * * * "
  time_zone = "Europe/London"
  region = var.region


  retry_config {
    retry_count = 0
  }

  http_target {
   http_method = "POST" 
   uri = "https://europe-west2-run.googleapis.com/apis/run.googleapis.com/v1/namespaces/tpx-dx-dashboards/jobs/runn-time-offs-rostered-days-off-pipe:run"
   oauth_token {
     service_account_email = var.serviceaccount
     scope = "https://www.googleapis.com/auth/cloud-platform"
   }
  }
}



resource "google_cloud_run_v2_job" "hello_python" {
  # Only google-beta provider supports gcs container mount.
  name = "hello-python"
  location = var.region

  deletion_protection =  false

  template {
    task_count = 1
    template {
      service_account = var.pipelines_serviceaccount
      containers {
        name = "python"
        image = data.google_artifact_registry_docker_image.hello_python.self_link

        working_dir = "/app"
        command = ["uv", "run", "python", "-m", "src.main"]
      }
    }
  }
}

resource "google_cloud_run_v2_job" "runn_actuals" {
  name     = "runn-actuals-pipe"
  location = var.region

  deletion_protection = false

  template {
    task_count = 1
    template {
      service_account = var.pipelines_serviceaccount
      containers {
        name  = "python"
        image = data.google_artifact_registry_docker_image.runn_actuals.self_link

        working_dir = "/app"
        command     = ["uv", "run", "python", "-m", "src.main"]
      }
    }
  }
}

resource "google_cloud_run_v2_job" "runn_project_budget_roles" {
  name     = "runn-project-budget-roles-pipe"
  location = var.region

  deletion_protection = false

  template {
    task_count = 1
    template {
      service_account = var.pipelines_serviceaccount
      containers {
        name  = "python"
        image = data.google_artifact_registry_docker_image.runn_project_budget_roles.self_link

        working_dir = "/app"
        command     = ["uv", "run", "python", "-m", "src.main"]
      }
    }
  }
}

resource "google_cloud_run_v2_job" "runn_per_project_rates" {
  name     = "runn-per-project-rates-pipe"
  location = var.region

  deletion_protection = false

  template {
    task_count = 1
    template {
      service_account = var.pipelines_serviceaccount
      containers {
        name  = "python"
        image = data.google_artifact_registry_docker_image.runn_per_project_rates.self_link

        working_dir = "/app"
        command     = ["uv", "run", "python", "-m", "src.main"]
      }
    }
  }
}

resource "google_cloud_run_v2_job" "runn_placeholders" {
  name     = "runn-placeholders-pipe"
  location = var.region

  deletion_protection = false

  template {
    task_count = 1
    template {
      service_account = var.pipelines_serviceaccount
      containers {
        name  = "python"
        image = data.google_artifact_registry_docker_image.runn_placeholders.self_link

        working_dir = "/app"
        command     = ["uv", "run", "python", "-m", "src.main"]
      }
    }
  }
}

resource "google_cloud_run_v2_job" "runn_project_other_expenses" {
  name     = "runn-project-other-expenses-pipe"
  location = var.region

  deletion_protection = false

  template {
    task_count = 1
    template {
      service_account = var.pipelines_serviceaccount
      containers {
        name  = "python"
        image = data.google_artifact_registry_docker_image.runn_project_other_expenses.self_link

        working_dir = "/app"
        command     = ["uv", "run", "python", "-m", "src.main"]
      }
    }
  }
}

resource "google_cloud_run_v2_job" "runn_time_offs_holidays" {
  name     = "runn-time-offs-holidays-pipe"
  location = var.region

  deletion_protection = false

  template {
    task_count = 1
    template {
      service_account = var.pipelines_serviceaccount
      containers {
        name  = "python"
        image = data.google_artifact_registry_docker_image.runn_time_offs_holidays.self_link

        working_dir = "/app"
        command     = ["uv", "run", "python", "-m", "src.main"]
      }
    }
  }
}

resource "google_cloud_run_v2_job" "runn_time_offs_leave" {
  name     = "runn-time-offs-leave-pipe"
  location = var.region

  deletion_protection = false

  template {
    task_count = 1
    template {
      service_account = var.pipelines_serviceaccount
      containers {
        name  = "python"
        image = data.google_artifact_registry_docker_image.runn_time_offs_leave.self_link

        working_dir = "/app"
        command     = ["uv", "run", "python", "-m", "src.main"]
      }
    }
  }
}

resource "google_cloud_run_v2_job" "runn_time_offs_rostered_days_off" {
  name     = "runn-time-offs-rostered-days-off-pipe"
  location = var.region

  deletion_protection = false

  template {
    task_count = 1
    template {
      service_account = var.pipelines_serviceaccount
      containers {
        name  = "python"
        image = data.google_artifact_registry_docker_image.runn_time_offs_rostered_days_off.self_link

        working_dir = "/app"
        command     = ["uv", "run", "python", "-m", "src.main"]
      }
    }
  }
}

data "google_artifact_registry_docker_image" "hello_python" {
  location = google_artifact_registry_repository.cloud_run_images.location
  repository_id = google_artifact_registry_repository.cloud_run_images.repository_id
  image_name = "hello-python@${docker_registry_image.hello_python.sha256_digest}"
}

data "google_artifact_registry_docker_image" "runn_actuals" {
  location      = google_artifact_registry_repository.cloud_run_images.location
  repository_id = google_artifact_registry_repository.cloud_run_images.repository_id
  image_name    = "runn-actuals-pipe@${docker_registry_image.runn_actuals.sha256_digest}"
}

data "google_artifact_registry_docker_image" "runn_project_budget_roles" {
  location      = google_artifact_registry_repository.cloud_run_images.location
  repository_id = google_artifact_registry_repository.cloud_run_images.repository_id
  image_name    = "runn-project-budget-roles-pipe@${docker_registry_image.runn_project_budget_roles.sha256_digest}"
}

data "google_artifact_registry_docker_image" "runn_per_project_rates" {
  location      = google_artifact_registry_repository.cloud_run_images.location
  repository_id = google_artifact_registry_repository.cloud_run_images.repository_id
  image_name    = "runn-per-project-rates-pipe@${docker_registry_image.runn_per_project_rates.sha256_digest}"
}

data "google_artifact_registry_docker_image" "runn_placeholders" {
  location      = google_artifact_registry_repository.cloud_run_images.location
  repository_id = google_artifact_registry_repository.cloud_run_images.repository_id
  image_name    = "runn-placeholders-pipe@${docker_registry_image.runn_placeholders.sha256_digest}"
}

data "google_artifact_registry_docker_image" "runn_project_other_expenses" {
  location      = google_artifact_registry_repository.cloud_run_images.location
  repository_id = google_artifact_registry_repository.cloud_run_images.repository_id
  image_name    = "runn-project-other-expenses-pipe@${docker_registry_image.runn_project_other_expenses.sha256_digest}"
}

data "google_artifact_registry_docker_image" "runn_time_offs_holidays" {
  location      = google_artifact_registry_repository.cloud_run_images.location
  repository_id = google_artifact_registry_repository.cloud_run_images.repository_id
  image_name    = "runn-time-offs-holidays-pipe@${docker_registry_image.runn_time_offs_holidays.sha256_digest}"
}

data "google_artifact_registry_docker_image" "runn_time_offs_leave" {
  location      = google_artifact_registry_repository.cloud_run_images.location
  repository_id = google_artifact_registry_repository.cloud_run_images.repository_id
  image_name    = "runn-time-offs-leave-pipe@${docker_registry_image.runn_time_offs_leave.sha256_digest}"
}

data "google_artifact_registry_docker_image" "runn_time_offs_rostered_days_off" {
  location      = google_artifact_registry_repository.cloud_run_images.location
  repository_id = google_artifact_registry_repository.cloud_run_images.repository_id
  image_name    = "runn-time-offs-rostered-days-off-pipe@${docker_registry_image.runn_time_offs_rostered_days_off.sha256_digest}"
}


resource "google_artifact_registry_repository" "cloud_run_images" {
  location = var.region
  repository_id = "cloud-run-images"
  description = "Repository for cloud run docker images"
  format = "DOCKER"
}


resource "docker_registry_image" "hello_python" {
  name = docker_image.hello_python.name
  keep_remotely = true

  triggers = {
    image_sha = docker_image.hello_python.repo_digest
  }
}

resource "docker_registry_image" "runn_actuals" {
  name          = docker_image.runn_actuals.name
  keep_remotely = true

  triggers = {
    image_sha = docker_image.runn_actuals.repo_digest
  }
}

resource "docker_registry_image" "runn_project_budget_roles" {
  name          = docker_image.runn_project_budget_roles.name
  keep_remotely = true

  triggers = {
    image_sha = docker_image.runn_project_budget_roles.repo_digest
  }
}

resource "docker_registry_image" "runn_per_project_rates" {
  name          = docker_image.runn_per_project_rates.name
  keep_remotely = true

  triggers = {
    image_sha = docker_image.runn_per_project_rates.repo_digest
  }
}

resource "docker_registry_image" "runn_placeholders" {
  name          = docker_image.runn_placeholders.name
  keep_remotely = true

  triggers = {
    image_sha = docker_image.runn_placeholders.repo_digest
  }
}

resource "docker_registry_image" "runn_project_other_expenses" {
  name          = docker_image.runn_project_other_expenses.name
  keep_remotely = true

  triggers = {
    image_sha = docker_image.runn_project_other_expenses.repo_digest
  }
}

resource "docker_registry_image" "runn_time_offs_holidays" {
  name          = docker_image.runn_time_offs_holidays.name
  keep_remotely = true

  triggers = {
    image_sha = docker_image.runn_time_offs_holidays.repo_digest
  }
}

resource "docker_registry_image" "runn_time_offs_leave" {
  name          = docker_image.runn_time_offs_leave.name
  keep_remotely = true

  triggers = {
    image_sha = docker_image.runn_time_offs_leave.repo_digest
  }
}

resource "docker_registry_image" "runn_time_offs_rostered_days_off" {
  name          = docker_image.runn_time_offs_rostered_days_off.name
  keep_remotely = true

  triggers = {
    image_sha = docker_image.runn_time_offs_rostered_days_off.repo_digest
  }
}

locals {
  hello_python = {
    context_dir      = "${path.root}/../../../cloud_run_jobs/test/hello_python"
    dockerfile_path  = "${path.root}/../../../docker-images/jobs.Dockerfile"
  }

  runn_actuals = {
    context_dir      = "${path.root}/../../../cloud_run_jobs/runn/actuals"
    dockerfile_path  = "${path.root}/../../../docker-images/jobs.Dockerfile"
  }

  runn_project_budget_roles = {
    context_dir      = "${path.root}/../../../cloud_run_jobs/runn/project_budget_roles"
    dockerfile_path  = "${path.root}/../../../docker-images/jobs.Dockerfile"
  }

  runn_per_project_rates = {
    context_dir      = "${path.root}/../../../cloud_run_jobs/runn/per_project_rates"
    dockerfile_path  = "${path.root}/../../../docker-images/jobs.Dockerfile"
  }

  runn_placeholders = {
    context_dir      = "${path.root}/../../../cloud_run_jobs/runn/placeholders"
    dockerfile_path  = "${path.root}/../../../docker-images/jobs.Dockerfile"
  }

  runn_project_other_expenses = {
    context_dir      = "${path.root}/../../../cloud_run_jobs/runn/project_other_expenses"
    dockerfile_path  = "${path.root}/../../../docker-images/jobs.Dockerfile"
  }

  runn_time_offs_holidays = {
    context_dir      = "${path.root}/../../../cloud_run_jobs/runn/time_offs_holidays"
    dockerfile_path  = "${path.root}/../../../docker-images/jobs.Dockerfile"
  }

  runn_time_offs_leave = {
    context_dir      = "${path.root}/../../../cloud_run_jobs/runn/time_offs_leave"
    dockerfile_path  = "${path.root}/../../../docker-images/jobs.Dockerfile"
  }

  runn_time_offs_rostered_days_off = {
    context_dir      = "${path.root}/../../../cloud_run_jobs/runn/time_offs_rostered_days_off"
    dockerfile_path  = "${path.root}/../../../docker-images/jobs.Dockerfile"
  }
}

resource "docker_image" "hello_python" {
  name = "${var.region}-docker.pkg.dev/${var.project}/${google_artifact_registry_repository.cloud_run_images.repository_id}/hello-python"
  build {
    context = local.hello_python.context_dir
    dockerfile = local.hello_python.dockerfile_path
  }

  force_remove = true

  triggers = {
        dir_sha1 = sha1(join("", [for f in fileset(local.hello_python.context_dir, "**") : filesha1("${local.hello_python.context_dir}/${f}")]))

  }
}

resource "docker_image" "runn_actuals" {
  name = "${var.region}-docker.pkg.dev/${var.project}/${google_artifact_registry_repository.cloud_run_images.repository_id}/runn-actuals-pipe"
  build {
    context    = local.runn_actuals.context_dir
    dockerfile = local.runn_actuals.dockerfile_path
  }

  force_remove = true

  triggers = {
    dir_sha1 = sha1(join("", [for f in fileset(local.runn_actuals.context_dir, "**") : filesha1("${local.runn_actuals.context_dir}/${f}")]))
  }
}

resource "docker_image" "runn_project_budget_roles" {
  name = "${var.region}-docker.pkg.dev/${var.project}/${google_artifact_registry_repository.cloud_run_images.repository_id}/runn-project-budget-roles-pipe"
  build {
    context    = local.runn_project_budget_roles.context_dir
    dockerfile = local.runn_project_budget_roles.dockerfile_path
  }

  force_remove = true

  triggers = {
    dir_sha1 = sha1(join("", [for f in fileset(local.runn_project_budget_roles.context_dir, "**") : filesha1("${local.runn_project_budget_roles.context_dir}/${f}")]))
  }
}

resource "docker_image" "runn_per_project_rates" {
  name = "${var.region}-docker.pkg.dev/${var.project}/${google_artifact_registry_repository.cloud_run_images.repository_id}/runn-per-project-rates-pipe"
  build {
    context    = local.runn_per_project_rates.context_dir
    dockerfile = local.runn_per_project_rates.dockerfile_path
  }

  force_remove = true

  triggers = {
    dir_sha1 = sha1(join("", [for f in fileset(local.runn_per_project_rates.context_dir, "**") : filesha1("${local.runn_per_project_rates.context_dir}/${f}")]))
  }
}

resource "docker_image" "runn_placeholders" {
  name = "${var.region}-docker.pkg.dev/${var.project}/${google_artifact_registry_repository.cloud_run_images.repository_id}/runn-placeholders-pipe"
  build {
    context    = local.runn_placeholders.context_dir
    dockerfile = local.runn_placeholders.dockerfile_path
  }

  force_remove = true

  triggers = {
    dir_sha1 = sha1(join("", [for f in fileset(local.runn_placeholders.context_dir, "**") : filesha1("${local.runn_placeholders.context_dir}/${f}")]))
  }
}

resource "docker_image" "runn_project_other_expenses" {
  name = "${var.region}-docker.pkg.dev/${var.project}/${google_artifact_registry_repository.cloud_run_images.repository_id}/runn-project-other-expenses-pipe"
  build {
    context    = local.runn_project_other_expenses.context_dir
    dockerfile = local.runn_project_other_expenses.dockerfile_path
  }

  force_remove = true

  triggers = {
    dir_sha1 = sha1(join("", [for f in fileset(local.runn_project_other_expenses.context_dir, "**") : filesha1("${local.runn_project_other_expenses.context_dir}/${f}")]))
  }
}

resource "docker_image" "runn_time_offs_holidays" {
  name = "${var.region}-docker.pkg.dev/${var.project}/${google_artifact_registry_repository.cloud_run_images.repository_id}/runn-time-offs-holidays-pipe"
  build {
    context    = local.runn_time_offs_holidays.context_dir
    dockerfile = local.runn_time_offs_holidays.dockerfile_path
  }

  force_remove = true

  triggers = {
    dir_sha1 = sha1(join("", [for f in fileset(local.runn_time_offs_holidays.context_dir, "**") : filesha1("${local.runn_time_offs_holidays.context_dir}/${f}")]))
  }
}

resource "docker_image" "runn_time_offs_leave" {
  name = "${var.region}-docker.pkg.dev/${var.project}/${google_artifact_registry_repository.cloud_run_images.repository_id}/runn-time-offs-leave-pipe"
  build {
    context    = local.runn_time_offs_leave.context_dir
    dockerfile = local.runn_time_offs_leave.dockerfile_path
  }

  force_remove = true

  triggers = {
    dir_sha1 = sha1(join("", [for f in fileset(local.runn_time_offs_leave.context_dir, "**") : filesha1("${local.runn_time_offs_leave.context_dir}/${f}")]))
  }
}

resource "docker_image" "runn_time_offs_rostered_days_off" {
  name = "${var.region}-docker.pkg.dev/${var.project}/${google_artifact_registry_repository.cloud_run_images.repository_id}/runn-time-offs-rostered-days-off-pipe"
  build {
    context    = local.runn_time_offs_rostered_days_off.context_dir
    dockerfile = local.runn_time_offs_rostered_days_off.dockerfile_path
  }

  force_remove = true

  triggers = {
    dir_sha1 = sha1(join("", [for f in fileset(local.runn_time_offs_rostered_days_off.context_dir, "**") : filesha1("${local.runn_time_offs_rostered_days_off.context_dir}/${f}")]))
  }
}