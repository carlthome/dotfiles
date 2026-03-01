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

# Service account for Terraform (infra workflow).
resource "google_service_account" "github_actions_terraform" {
  account_id   = "github-actions-terraform"
  display_name = "GitHub Actions Terraform Service Account"
  description  = "Used by GitHub Actions for Terraform deployments"
}

# Service account for application build and deploy (app workflow).
resource "google_service_account" "github_actions_deploy" {
  account_id   = "github-actions-deploy"
  display_name = "GitHub Actions Deploy Service Account"
  description  = "Used by GitHub Actions for building and deploying the application"
}

# Grant admin roles to the Terraform service account.
resource "google_project_iam_member" "github_actions_terraform_roles" {
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
    "roles/iam.workloadIdentityPoolAdmin",
  ])
  project = data.google_client_config.current.project
  role    = each.value
  member  = "serviceAccount:${google_service_account.github_actions_terraform.email}"
}

# Grant minimal roles to the deploy service account.
resource "google_project_iam_member" "github_actions_deploy_roles" {
  for_each = toset([
    "roles/artifactregistry.writer",
    "roles/run.developer",
  ])
  project = data.google_client_config.current.project
  role    = each.value
  member  = "serviceAccount:${google_service_account.github_actions_deploy.email}"
}

# Allow Terraform SA to impersonate via WIF.
resource "google_service_account_iam_member" "github_actions_terraform_wif" {
  service_account_id = google_service_account.github_actions_terraform.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/projects/${data.google_project.current.number}/locations/global/workloadIdentityPools/${google_iam_workload_identity_pool.github.workload_identity_pool_id}/attribute.repository/${var.github_repo}"
}

# Allow deploy SA to impersonate via WIF.
resource "google_service_account_iam_member" "github_actions_deploy_wif" {
  service_account_id = google_service_account.github_actions_deploy.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/projects/${data.google_project.current.number}/locations/global/workloadIdentityPools/${google_iam_workload_identity_pool.github.workload_identity_pool_id}/attribute.repository/${var.github_repo}"
}

# Create GitHub Actions environment and secrets.
resource "github_repository_environment" "production" {
  environment = "production"
  repository  = local.github_repo_name
}

resource "github_actions_environment_variable" "workload_identity_provider" {
  environment   = github_repository_environment.production.environment
  variable_name = "GOOGLE_CLOUD_WORKLOAD_IDENTITY_PROVIDER"
  value         = "projects/${data.google_project.current.number}/locations/global/workloadIdentityPools/${google_iam_workload_identity_pool.github.workload_identity_pool_id}/providers/${google_iam_workload_identity_pool_provider.github.workload_identity_pool_provider_id}"
  repository    = local.github_repo_name
}

resource "github_actions_environment_variable" "deploy_service_account" {
  environment   = github_repository_environment.production.environment
  variable_name = "GOOGLE_CLOUD_DEPLOY_SERVICE_ACCOUNT"
  value         = google_service_account.github_actions_deploy.email
  repository    = local.github_repo_name
}

resource "github_actions_environment_variable" "terraform_service_account" {
  environment   = github_repository_environment.production.environment
  variable_name = "GOOGLE_CLOUD_TERRAFORM_SERVICE_ACCOUNT"
  value         = google_service_account.github_actions_terraform.email
  repository    = local.github_repo_name
}

resource "github_actions_environment_variable" "google_cloud_project" {
  environment   = github_repository_environment.production.environment
  variable_name = "GOOGLE_CLOUD_PROJECT"
  value         = var.google_project
  repository    = local.github_repo_name
}

resource "github_actions_environment_variable" "google_cloud_region" {
  environment   = github_repository_environment.production.environment
  variable_name = "GOOGLE_CLOUD_REGION"
  value         = var.google_region
  repository    = local.github_repo_name
}
