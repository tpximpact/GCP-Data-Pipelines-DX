variable "region" {
  default = "europe-west2"
}

variable "project" {
  default = "tpx-dx-dashboards"
}

variable "env" {
  default = "dev"
}

variable "serviceaccount" {
  # Main service account
  default = "tpx-dx-dashboards@appspot.gserviceaccount.com"
}

variable "pipelines_serviceaccount" {
  # Ingests data from runn/hubspot/invoices and runs dataform workflows.
  default = "dashboard-pipelines@tpx-dx-dashboards.iam.gserviceaccount.com"
}


variable "frontend_serviceaccount" {
  # Runs the site 'frontend' app.
  default = "firebase-app-hosting-compute@tpx-dx-dashboards.iam.gserviceaccount.com"
}

variable "deploy_serviceaccount" {
    default = "infra-deploy@tpx-dx-dashboards.iam.gserviceaccount.com"
}


variable "job_timeout" {
  # 30 minutes
  default = "1800s"
}