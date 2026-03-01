terraform {
  backend "gcs" {
    # Bucket is passed at init time via -backend-config (set as TERRAFORM_STATE_BUCKET_NAME GitHub secret).
    prefix = "terraform/ping-home/state"
  }
  required_providers {
    google = { source = "hashicorp/google", version = "~> 5.0" }
    github = { source = "integrations/github", version = "~> 6.0" }
  }
}

provider "google" {
  project = var.google_project
  region  = var.google_region
}

provider "github" {
  owner = split("/", var.github_repo)[0]
  # Uses GITHUB_TOKEN environment variable
}

data "google_client_config" "current" {}

resource "google_project_service" "apis" {
  for_each = toset([
    "artifactregistry.googleapis.com",
    "cloudscheduler.googleapis.com",
    "iam.googleapis.com",
    "iamcredentials.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "run.googleapis.com",
  ])
  service            = each.value
  disable_on_destroy = false
}
