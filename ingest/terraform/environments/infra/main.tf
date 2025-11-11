terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "3.6.2"
    }
  }
}


# We need a service account oauth token for the 
data "google_service_account_access_token" "artifact_registry_access_token" {
  target_service_account = var.deploy_serviceaccount
  scopes                 = ["cloud-platform"]
}

# Used for building docker images and pushing up to google artifact registry.
provider "docker" {
  host = "unix:///var/run/docker.sock"

  registry_auth {
    address = "${var.region}-docker.pkg.dev"
    username = "oauth2accesstoken"
    password = data.google_service_account_access_token.artifact_registry_access_token.access_token
  }
}

provider "google" {
  project = var.project
  region  = var.region

  # Ensure consistent deploy regardless of deployer.
  # Deployer needs the roles/iam.serviceAccountTokenCreator against deploy_serviceaccount
  # See https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/provider_reference#impersonate_service_account-1
  # Any infrastructure you build should be owned by.
  impersonate_service_account = var.deploy_serviceaccount
}


data "google_project" "project_number" {

}