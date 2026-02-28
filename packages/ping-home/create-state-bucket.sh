#!/usr/bin/env bash
# Setup Terraform backend bucket (admin-only task).
set -euo pipefail

# Load from .env if not already in environment
# shellcheck source=/dev/null
[ -f .env ] && set -a && source .env && set +a

# Only prompt if not already set
[ -z "${GOOGLE_CLOUD_PROJECT:-}" ] && read -rp "GCP Project ID: " GOOGLE_CLOUD_PROJECT
[ -z "${GOOGLE_CLOUD_REGION:-}" ] && read -rp "GCP Region: " GOOGLE_CLOUD_REGION
[ -z "${TERRAFORM_STATE_BUCKET_NAME:-}" ] && read -rp "Terraform State bucket name: " TERRAFORM_STATE_BUCKET_NAME

export GOOGLE_CLOUD_PROJECT GOOGLE_CLOUD_REGION CLOUDSDK_CORE_PROJECT="$GOOGLE_CLOUD_PROJECT"

# Enable minimal APIs for state management.
gcloud services enable \
	cloudresourcemanager.googleapis.com \
	storage.googleapis.com

# Create Terraform state bucket (if missing).
if ! gcloud storage buckets describe "gs://$TERRAFORM_STATE_BUCKET_NAME" >/dev/null 2>&1; then
	gcloud storage buckets create "gs://$TERRAFORM_STATE_BUCKET_NAME" \
		--location="$GOOGLE_CLOUD_REGION" 2>/dev/null || true
fi

echo "Terraform backend bucket created: gs://$TERRAFORM_STATE_BUCKET_NAME"
