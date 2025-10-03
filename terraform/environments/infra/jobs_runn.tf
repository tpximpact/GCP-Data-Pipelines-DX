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
