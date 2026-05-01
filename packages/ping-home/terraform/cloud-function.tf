resource "google_service_account" "heartbeat" {
  account_id   = "heartbeat-function"
  display_name = "Heartbeat Cloud Function"
}

resource "google_project_iam_member" "heartbeat_metrics" {
  project = var.google_project
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.heartbeat.email}"
}

resource "google_monitoring_alert_policy" "heartbeat_missing" {
  display_name = "Home heartbeat missing"
  combiner     = "OR"
  severity     = "CRITICAL"

  conditions {
    display_name = "No heartbeat for 10 minutes"
    condition_absent {
      filter   = "resource.type = \"global\" AND metric.type = \"custom.googleapis.com/home/heartbeat\""
      duration = "600s"
      aggregations {
        alignment_period   = "300s"
        per_series_aligner = "ALIGN_COUNT"
      }
    }
  }

  notification_channels = [google_monitoring_notification_channel.email.name]
}

output "heartbeat_service_account" {
  value = google_service_account.heartbeat.email
}
