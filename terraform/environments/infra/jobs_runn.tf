# Custom gcloud provider to run gcloud cli commands

module "runn_actuals_pipe" {
 source  = "terraform-google-modules/gcloud/google"
 version = "~> 4.0"

 platform = "linux"

 create_cmd_entrypoint = "${path.module}/scripts/runn_pipe.sh"
 create_cmd_body       = "create ${path.module}/../../../cloud_run_jobs/runn/actuals runn-actuals-pipe"

 destroy_cmd_entrypoint = "${path.module}/scripts/runn_pipe.sh"
 destroy_cmd_body       = "destroy runn-actuals-pipe"
}


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

module "runn_project_budget_roles_pipe" {
 source  = "terraform-google-modules/gcloud/google"
 version = "~> 4.0"

 platform = "linux"

 create_cmd_entrypoint = "${path.module}/scripts/runn_pipe.sh"
 create_cmd_body       = "create ${path.module}/../../../cloud_run_jobs/runn/project-budget-roles runn-project-budget-roles-pipe"

 destroy_cmd_entrypoint = "${path.module}/scripts/runn_pipe.sh"
 destroy_cmd_body       = "destroy runn-project-budget-roles-pipe"
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


module "runn_per_project_rates_pipe" {
 source  = "terraform-google-modules/gcloud/google"
 version = "~> 4.0"

 platform = "linux"

 create_cmd_entrypoint = "${path.module}/scripts/runn_pipe.sh"
 create_cmd_body       = "create ${path.module}/../../../cloud_run_jobs/runn/per_project_rates runn-per-project-rates-pipe"

 destroy_cmd_entrypoint = "${path.module}/scripts/runn_pipe.sh"
 destroy_cmd_body       = "destroy runn-per-project-rates-pipe"
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


module "runn_placeholders_pipe" {
 source  = "terraform-google-modules/gcloud/google"
 version = "~> 4.0"

 platform = "linux"

 create_cmd_entrypoint = "${path.module}/scripts/runn_pipe.sh"
 create_cmd_body       = "create ${path.module}/../../../cloud_run_jobs/runn/placeholders runn-placeholders-pipe"

 destroy_cmd_entrypoint = "${path.module}/scripts/runn_pipe.sh"
 destroy_cmd_body       = "destroy runn-placeholders-pipe"
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

module "runn_project_other_expenses_pipe" {
 source  = "terraform-google-modules/gcloud/google"
 version = "~> 4.0"

 platform = "linux"

 create_cmd_entrypoint = "${path.module}/scripts/runn_pipe.sh"
 create_cmd_body       = "create ${path.module}/../../../cloud_run_jobs/runn/project_other_expenses runn-project-other-expenses-pipe"

 destroy_cmd_entrypoint = "${path.module}/scripts/runn_pipe.sh"
 destroy_cmd_body       = "destroy runn-project-other-expenses-pipe"
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


module "runn_time_offs_holidays_pipe" {
 source  = "terraform-google-modules/gcloud/google"
 version = "~> 4.0"

 platform = "linux"

 create_cmd_entrypoint = "${path.module}/scripts/runn_pipe.sh"
 create_cmd_body       = "create ${path.module}/../../../cloud_run_jobs/runn/time_offs_holidays runn-time-offs-holidays-pipe"

 destroy_cmd_entrypoint = "${path.module}/scripts/runn_pipe.sh"
 destroy_cmd_body       = "destroy runn-time-offs-holidays-pipe"
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

module "runn_time_offs_leave_pipe" {
 source  = "terraform-google-modules/gcloud/google"
 version = "~> 4.0"

 platform = "linux"

 create_cmd_entrypoint = "${path.module}/scripts/runn_pipe.sh"
 create_cmd_body       = "create ${path.module}/../../../cloud_run_jobs/runn/time_offs_leave runn-time-offs-leave-pipe"

 destroy_cmd_entrypoint = "${path.module}/scripts/runn_pipe.sh"
 destroy_cmd_body       = "destroy runn-time-offs-leave-pipe"
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


module "runn_time_offs_rostered_days_off_pipe" {
 source  = "terraform-google-modules/gcloud/google"
 version = "~> 4.0"

 platform = "linux"

 create_cmd_entrypoint = "${path.module}/scripts/runn_pipe.sh"
 create_cmd_body       = "create ${path.module}/../../../cloud_run_jobs/runn/time_offs_rostered_days_off runn-time-offs-rostered-days-off-pipe"

 destroy_cmd_entrypoint = "${path.module}/scripts/runn_pipe.sh"
 destroy_cmd_body       = "destroy runn-time-offs-rostered-days-off-pipe"
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

data "google_artifact_registry_docker_image" "hello_python" {
  location = google_artifact_registry_repository.cloud_run_images.location
  repository_id = google_artifact_registry_repository.cloud_run_images.repository_id
  image_name = "hello-python@${docker_registry_image.hello_python.sha256_digest}"
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

locals {
  hello_python = {
  context_dir = "${path.root}/../../../cloud_run_jobs/test/hello_python"
  dockerfile_path = "${path.root}/../../../docker-images/jobs.Dockerfile"
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