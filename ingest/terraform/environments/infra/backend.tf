terraform {

  backend "gcs" {
    bucket = "tpx-dx-dashboards-tf-state"
    prefix = "terraform/state"
  }

}
