data "google_secret_manager_secret_version" "email" {
  secret  = "alert-email"
  project = data.google_client_config.current.project
}

resource "google_monitoring_notification_channel" "email" {
  display_name = "Home LAN Alerts"
  type         = "email"
  labels = { email_address = data.google_secret_manager_secret_version.email.secret_data }
}

resource "google_monitoring_alert_policy" "lan_down" {
  display_name = "Home LAN is DOWN"
  combiner     = "OR"
  conditions {
    display_name = "Function Exception Logged"
    condition_matched_log {
      filter = "resource.type=\"cloud_run_revision\" AND resource.labels.service_name=\"${google_cloud_run_v2_service.checker.name}\" AND severity>=ERROR"
    }
  }
  notification_channels = [google_monitoring_notification_channel.email.name]
  alert_strategy {
    notification_rate_limit { period = "3600s" }
  }
}
