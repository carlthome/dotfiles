variable "github_repo" {
  type        = string
  description = "GitHub repository in the format 'owner/repo'"
}

variable "google_region" {
  type        = string
  description = "GCP region for resources (e.g., europe-north1)"
  default     = "europe-north1"
}
