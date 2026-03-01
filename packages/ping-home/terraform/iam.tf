# Dedicated service account for the Cloud Run runtime.
# The GitHub Actions SA (managed by install.sh) handles deployment;
# this SA has only the permissions the running container actually needs.
resource "google_service_account" "cloudrun" {
  account_id   = "home-lan-checker"
  display_name = "Home LAN Checker (Cloud Run runtime)"
}

# Grant read access to the two secrets mounted into the container.
# alert-email is accessed by Terraform under the GitHub Actions SA, not at runtime.
resource "google_secret_manager_secret_iam_member" "cloudrun_home_lan_endpoint" {
  project   = data.google_client_config.current.project
  secret_id = "home-lan-endpoint"
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.cloudrun.email}"
}

resource "google_secret_manager_secret_iam_member" "cloudrun_tailscale_auth_key" {
  project   = data.google_client_config.current.project
  secret_id = "tailscale-auth-key"
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.cloudrun.email}"
}

# Allow the GitHub Actions SA to deploy as the Cloud Run SA.
resource "google_service_account_iam_member" "cloudrun_deploy" {
  service_account_id = google_service_account.cloudrun.name
  role               = "roles/iam.serviceAccountUser"
  member             = "serviceAccount:${google_service_account.github_actions_deploy.email}"
}

resource "google_service_account" "scheduler" {
  account_id   = "scheduler-invoker"
  display_name = "Scheduler Invoker"
}

resource "google_cloud_run_service_iam_member" "invoker" {
  service  = google_cloud_run_v2_service.checker.name
  location = google_cloud_run_v2_service.checker.location
  role     = "roles/run.invoker"
  member   = "serviceAccount:${google_service_account.scheduler.email}"
}
