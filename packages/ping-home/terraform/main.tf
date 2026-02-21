terraform {
  backend "gcs" {
    # Bucket is passed at init time via -backend-config (set as GCS_BUCKET_NAME GitHub secret).
    prefix = "terraform/ping-home/state"
  }
  required_providers {
    google = { source = "hashicorp/google", version = "~> 5.0" }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_artifact_registry_repository" "repo" {
  location      = var.region
  repository_id = "lan-checker-repo"
  description   = "Docker repository for the Home LAN Checker"
  format        = "DOCKER"
}

resource "google_cloud_run_v2_service" "checker" {
  name     = "home-lan-checker"
  location = var.region
  template {
    containers {
      image = "us-docker.pkg.dev/cloudrun/container/hello"
      env {
        name = "HOME_LAN_ENDPOINT"
        value_source { secret_key_ref { secret = "home-lan-endpoint", version = "latest" } }
      }
      env {
        name = "TAILSCALE_AUTH_KEY"
        value_source { secret_key_ref { secret = "tailscale-auth-key", version = "latest" } }
      }
    }
  }
  lifecycle { ignore_changes = [template[0].containers[0].image] }
}

resource "google_cloud_scheduler_job" "cron" {
  name             = "trigger-lan-check"
  description      = "Pings the home LAN every 5 minutes"
  schedule         = "*/5 * * * *"
  time_zone        = "UTC"
  attempt_deadline = "30s"
  http_target {
    http_method = "GET"
    uri         = google_cloud_run_v2_service.checker.uri
    oidc_token { service_account_email = google_cloud_run_v2_service.checker.service_account_email }
  }
}
