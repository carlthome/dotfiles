resource "google_cloud_scheduler_job" "cron" {
  depends_on       = [google_project_service.apis]
  name             = "trigger-lan-check"
  region           = "europe-west1"
  description      = "Pings the home LAN every 5 minutes"
  schedule         = "*/5 * * * *"
  time_zone        = "UTC"
  attempt_deadline = "30s"
  http_target {
    http_method = "GET"
    uri         = google_cloud_run_v2_service.checker.uri
    oidc_token {
      service_account_email = google_service_account.cloudrun.email
      audience              = "${google_cloud_run_v2_service.checker.uri}/"
    }
  }
}
