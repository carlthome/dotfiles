resource "google_cloud_run_v2_service" "checker" {
  name     = "home-lan-checker"
  location = var.google_region
  ingress  = "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER"
  template {
    service_account = google_service_account.cloudrun.email
    scaling {
      min_instance_count = 0
      max_instance_count = 1
    }
    max_instance_request_concurrency = 1
    volumes {
      name = "home-lan-endpoint"
      secret {
        secret = google_secret_manager_secret.home_lan_endpoint.secret_id
        items {
          version = "latest"
          path    = "home-lan-endpoint"
        }
      }
    }
    volumes {
      name = "tailscale-auth-key"
      secret {
        secret = google_secret_manager_secret.tailscale_auth_key.secret_id
        items {
          version = "latest"
          path    = "tailscale-auth-key"
        }
      }
    }
    containers {
      image = "us-docker.pkg.dev/cloudrun/container/hello"
      resources {
        limits = {
          cpu    = "1000m"
          memory = "512Mi"
        }
        cpu_idle = true
      }
      volume_mounts {
        name       = "home-lan-endpoint"
        mount_path = "/secrets/home-lan-endpoint"
      }
      volume_mounts {
        name       = "tailscale-auth-key"
        mount_path = "/secrets/tailscale-auth-key"
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
