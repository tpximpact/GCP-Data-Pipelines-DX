# Custom gcloud provider to run gcloud cli commands

module "runn_actuals_pipe" {
 source  = "terraform-google-modules/gcloud/google"
 version = "~> 4.0"

 platform = "linux"

 create_cmd_entrypoint = "${path.module}/scripts/runn_actuals_pipe.sh"
 create_cmd_body       = "create ${path.module}/../../../cloud_run_jobs/runn/actuals"

 destroy_cmd_entrypoint = "${path.module}/scripts/runn_actuals_pipe.sh"
 destroy_cmd_body       = "destroy"
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