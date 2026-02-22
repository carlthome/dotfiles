terraform {
  backend "gcs" {
    # Bucket is passed at init time via -backend-config (set as TERRAFORM_STATE_BUCKET_NAME GitHub secret).
    prefix = "terraform/ping-home/state"
  }
  required_providers {
    google = { source = "hashicorp/google", version = "~> 5.0" }
  }
}

provider "google" {
  # Reads GOOGLE_CLOUD_PROJECT and GOOGLE_REGION from env vars.
}

data "google_client_config" "current" {}

# APIs that are safe for Terraform to own.
# secretmanager, storage, iam, iamcredentials, and cloudresourcemanager
# are enabled by install.sh before Terraform runs for the first time.
resource "google_project_service" "apis" {
  for_each = toset([
    "artifactregistry.googleapis.com",
    "cloudscheduler.googleapis.com",
    "monitoring.googleapis.com",
    "run.googleapis.com",
  ])
  service            = each.value
  disable_on_destroy = false
}

resource "google_artifact_registry_repository" "repo" {
  location      = data.google_client_config.current.region
  repository_id = "lan-checker-repo"
  description   = "Docker repository for the Home LAN Checker"
  format        = "DOCKER"
  depends_on    = [google_project_service.apis]
}

resource "google_cloud_run_v2_service" "checker" {
  name     = "home-lan-checker"
  location = data.google_client_config.current.region
  template {
    service_account = google_service_account.cloudrun.email
    scaling {
      min_instance_count = 0
      max_instance_count = 1
    }
    max_instance_request_concurrency = 1
    containers {
      image = "us-docker.pkg.dev/cloudrun/container/hello"
      resources {
        limits = {
          cpu    = "1000m"
          memory = "256Mi"
        }
        cpu_idle = true # CPU only allocated during request processing
      }
      env {
        name = "HOME_LAN_ENDPOINT"
        value_source {
          secret_key_ref {
            secret  = "home-lan-endpoint"
            version = "latest"
          }
        }
      }
      env {
        name = "TS_AUTHKEY"
        value_source {
          secret_key_ref {
            secret  = "tailscale-auth-key"
            version = "latest"
          }
        }
      }
      env {
        name  = "TS_HOSTNAME"
        value = "gcp-health-checker"
      }
      env {
        name  = "TS_SOCKS5_SERVER"
        value = "localhost:1055"
      }
    }
  }
  lifecycle { ignore_changes = [template[0].containers[0].image] }
  depends_on = [
    google_project_service.apis,
    google_secret_manager_secret_iam_member.cloudrun_home_lan_endpoint,
    google_secret_manager_secret_iam_member.cloudrun_tailscale_auth_key,
  ]
}

resource "google_cloud_scheduler_job" "cron" {
  depends_on = [google_project_service.apis]
  name             = "trigger-lan-check"
  description      = "Pings the home LAN every 5 minutes"
  schedule         = "*/5 * * * *"
  time_zone        = "UTC"
  attempt_deadline = "30s"
  http_target {
    http_method = "GET"
    uri         = google_cloud_run_v2_service.checker.uri
    oidc_token {
      service_account_email = google_service_account.cloudrun.email
    }
  }
}
