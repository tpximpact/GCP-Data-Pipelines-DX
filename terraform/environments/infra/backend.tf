terraform {

  backend "gcs" {
    bucket = "tpx-dx-dashboards-data-pipelines-tf-state-prod"
    prefix = "terraform/state"
  }

}
