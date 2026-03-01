resource "google_cloud_run_v2_service" "checker" {
  name     = "home-lan-checker"
  location = var.google_region
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
        cpu_idle = true
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
