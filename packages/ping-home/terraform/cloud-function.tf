resource "google_service_account" "heartbeat" {
  account_id   = "heartbeat-function"
  display_name = "Heartbeat Cloud Function"
}

resource "google_project_iam_member" "heartbeat_metrics" {
  project = var.google_project
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.heartbeat.email}"
}

resource "google_service_account_iam_member" "deploy_can_use_heartbeat" {
  service_account_id = google_service_account.heartbeat.name
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${google_service_account.github_actions_deploy.email}"
}

resource "random_password" "heartbeat_secret" {
  length  = 32
  special = false
}

resource "google_secret_manager_secret" "heartbeat" {
  secret_id = "heartbeat-secret"
  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "heartbeat" {
  secret      = google_secret_manager_secret.heartbeat.id
  secret_data = random_password.heartbeat_secret.result
}

resource "google_secret_manager_secret_iam_member" "heartbeat_function_can_read" {
  secret_id = google_secret_manager_secret.heartbeat.secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.heartbeat.email}"
}

resource "google_monitoring_metric_descriptor" "heartbeat" {
  type         = "custom.googleapis.com/home/heartbeat"
  metric_kind  = "GAUGE"
  value_type   = "INT64"
  display_name = "Home Heartbeat"
  description  = "Heartbeat signal from home network"
}

resource "google_monitoring_alert_policy" "heartbeat_missing" {
  display_name = "Home heartbeat missing"
  combiner     = "OR"
  severity     = "CRITICAL"

  conditions {
    display_name = "No heartbeat for 10 minutes"
    condition_absent {
      filter   = "resource.type = \"global\" AND metric.type = \"${google_monitoring_metric_descriptor.heartbeat.type}\""
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
