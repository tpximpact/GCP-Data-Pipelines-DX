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
  schedule = "0 2 * * * "
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

# --------------------------actuals--------------------------------\
# data "archive_file" "runn_actuals" {
#   type        = "zip"
#   source_dir  = "../../../cloud_run_jobs/runn/actuals"
#   excludes = [ ".env" ]
#   output_path = "/tmp/runn_actuals.zip"
# }
#
# # Add source code zip to the Cloud Function's bucket
# resource "google_storage_bucket_object" "runn_actuals" {
#   source       = data.archive_file.runn_actuals.output_path
#   content_type = "application/zip"
#
#   # Append to the MD5 checksum of the files's content
#   # to force the zip to be updated as soon as a change occurs
#   name   = "cloud_run_job-${data.archive_file.runn_actuals.output_md5}.zip"
#   bucket = data.google_storage_bucket.job_bucket.name
# }
#
# resource "google_cloud_run_v2_job" "runn_actuals" {
#   name = "runn-actuals-pipe"
#   location = var.region
#   deletion_protection = false
#
#   template {
#     task_count = 1
#     template {
#       service_account = "tpx-dx-dashboards@appspot.gserviceaccount.com"
#       timeout = "3600s"
#       max_retries = 0
#
#       containers  {
#         image = "europe-west2-docker.pkg.dev/tpx-dx-dashboards/cloud-run-images/ingest"
#         command = ["python3", "-m", "src.main" ]
#       }
#     }
#   }
# }
