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
  default = "tpx-dx-dashboards@appspot.gserviceaccount.com"
}

variable "pipelines_serviceaccount" {
  default = "dashboard-pipelines@tpx-dx-dashboards.iam.gserviceaccount.com"
}
