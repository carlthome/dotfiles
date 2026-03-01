resource "google_secret_manager_secret" "home_lan_endpoint" {
  secret_id = "home-lan-endpoint"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret" "alert_email" {
  secret_id = "alert-email"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret" "tailscale_auth_key" {
  secret_id = "tailscale-auth-key"
  replication {
    auto {}
  }
}
