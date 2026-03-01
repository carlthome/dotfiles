# Workload Identity Federation setup for GitHub Actions.

# Get current project info (including project_number for WIF configuration)
data "google_project" "current" {
  project_id = data.google_client_config.current.project
}

# Extract repo name from "owner/repo" format for GitHub resources
locals {
  github_repo_name = split("/", var.github_repo)[1]
}

resource "google_iam_workload_identity_pool" "github" {
  workload_identity_pool_id = "github-pool"
  display_name              = "GitHub Actions Pool"
  disabled                  = false
  project                   = data.google_client_config.current.project
}

resource "google_iam_workload_identity_pool_provider" "github" {
  workload_identity_pool_id          = google_iam_workload_identity_pool.github.workload_identity_pool_id
  workload_identity_pool_provider_id = "github-provider"

  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.repository" = "assertion.repository"
  }
  attribute_condition = "assertion.repository == '${var.github_repo}'"

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }

  display_name = "GitHub Provider"
}

# Service account for GitHub Actions.
resource "google_service_account" "github_actions" {
  account_id   = "github-actions"
  display_name = "GitHub Actions Service Account"
  description  = "Used by GitHub Actions for Terraform deployments"
}

# Grant necessary roles to the GitHub Actions service account.
resource "google_project_iam_member" "github_actions_roles" {
  for_each = toset([
    "roles/run.admin",
    "roles/artifactregistry.admin",
    "roles/cloudscheduler.admin",
    "roles/logging.configWriter",
    "roles/monitoring.editor",
    "roles/serviceusage.serviceUsageAdmin",
    "roles/iam.serviceAccountAdmin",
    "roles/iam.serviceAccountUser",
    "roles/secretmanager.admin",
    "roles/storage.objectAdmin",
    "roles/resourcemanager.projectIamAdmin",
  ])
  project = data.google_client_config.current.project
  role    = each.value
  member  = "serviceAccount:${google_service_account.github_actions.email}"
}

# Allow GitHub Actions to impersonate the service account via WIF.
resource "google_service_account_iam_member" "github_actions_wifu" {
  service_account_id = google_service_account.github_actions.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/projects/${data.google_project.current.number}/locations/global/workloadIdentityPools/${google_iam_workload_identity_pool.github.workload_identity_pool_id}/attribute.repository/${var.github_repo}"
}

# Create GitHub Actions environment and secrets using the GitHub provider.
resource "github_repository_environment" "production" {
  environment = "production"
  repository  = local.github_repo_name
}

resource "github_actions_environment_secret" "workload_identity_provider" {
  environment     = github_repository_environment.production.environment
  secret_name     = "GOOGLE_CLOUD_WORKLOAD_IDENTITY_PROVIDER"
  plaintext_value = "projects/${data.google_project.current.number}/locations/global/workloadIdentityPools/${google_iam_workload_identity_pool.github.workload_identity_pool_id}/providers/${google_iam_workload_identity_pool_provider.github.workload_identity_pool_provider_id}"
  repository      = local.github_repo_name
}

resource "github_actions_environment_secret" "service_account" {
  environment     = github_repository_environment.production.environment
  secret_name     = "GOOGLE_CLOUD_SERVICE_ACCOUNT"
  plaintext_value = google_service_account.github_actions.email
  repository      = local.github_repo_name
}

resource "github_actions_environment_variable" "google_cloud_region" {
  environment   = github_repository_environment.production.environment
  variable_name = "GOOGLE_CLOUD_REGION"
  value         = var.google_region
  repository    = local.github_repo_name
}
