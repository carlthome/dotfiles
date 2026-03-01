resource "google_artifact_registry_repository" "repo" {
  location      = var.google_region
  repository_id = "lan-checker-repo"
  description   = "Docker repository for the Home LAN Checker"
  format        = "DOCKER"
  depends_on    = [google_project_service.apis]
}
