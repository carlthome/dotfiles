#!/usr/bin/env bash
set -euo pipefail

read -rp "GCP Project ID: " GOOGLE_CLOUD_PROJECT
read -rp "GitHub Repository (e.g., carlthome/dotfiles): " GITHUB_REPO
read -rp "Terraform State bucket name (e.g., carlthome-tf-state): " TERRAFORM_STATE_BUCKET_NAME
read -rp "Home LAN Endpoint (e.g., http://192.168.0.1:8080): " HOME_LAN_ENDPOINT
read -rp "Alert Email: " ALERT_EMAIL
read -rsp "Tailscale Auth Key (tskey-auth-...): " TAILSCALE_AUTH_KEY
echo

gcloud config set project "$GOOGLE_CLOUD_PROJECT"
PROJECT_NUMBER=$(gcloud projects describe "$GOOGLE_CLOUD_PROJECT" --format="value(projectNumber)")

# Enable APIs needed before Terraform can authenticate and store state.
gcloud services enable \
	cloudresourcemanager.googleapis.com \
	iamcredentials.googleapis.com \
	secretmanager.googleapis.com \
	storage.googleapis.com

gcloud storage buckets create "gs://$TERRAFORM_STATE_BUCKET_NAME" --location=europe-north1 2>/dev/null || true

# Populate Google Cloud with secrets.
for pair in \
	"home-lan-endpoint:$HOME_LAN_ENDPOINT" \
	"alert-email:$ALERT_EMAIL" \
	"tailscale-auth-key:$TAILSCALE_AUTH_KEY"; do
	name=${pair%%:*}
	value=${pair#*:}
	gcloud secrets create "$name" --replication-policy=automatic 2>/dev/null || true
	echo -n "$value" | gcloud secrets versions add "$name" --data-file=- >/dev/null
done

# Create Workload Identity Federation setup for Google Cloud and GitHub Actions.
GITHUB_ACTIONS_SERVICE_ACCOUNT="github-actions@$GOOGLE_CLOUD_PROJECT.iam.gserviceaccount.com"
gcloud iam service-accounts create github-actions --display-name="GitHub Actions SA" 2>/dev/null || true
for role in \
	roles/run.admin \
	roles/artifactregistry.admin \
	roles/cloudscheduler.admin \
	roles/monitoring.editor \
	roles/serviceusage.serviceUsageAdmin \
	roles/iam.serviceAccountAdmin \
	roles/iam.serviceAccountUser \
	roles/secretmanager.admin \
	roles/storage.objectAdmin; do
	gcloud projects add-iam-policy-binding "$GOOGLE_CLOUD_PROJECT" \
		--member="serviceAccount:$GITHUB_ACTIONS_SERVICE_ACCOUNT" --role="$role" >/dev/null
done

gcloud iam workload-identity-pools create github-pool \
	--project="$GOOGLE_CLOUD_PROJECT" --location=global \
	--display-name="GitHub Actions Pool" 2>/dev/null || true

gcloud iam workload-identity-pools providers create-oidc github-provider \
	--project="$GOOGLE_CLOUD_PROJECT" --location=global \
	--workload-identity-pool=github-pool \
	--display-name="GitHub Provider" \
	--attribute-mapping="google.subject=assertion.sub,attribute.actor=assertion.actor,attribute.repository=assertion.repository" \
	--attribute-condition="assertion.repository == '$GITHUB_REPO'" \
	--issuer-uri="https://token.actions.githubusercontent.com" 2>/dev/null || true

gcloud iam service-accounts add-iam-policy-binding "$GITHUB_ACTIONS_SERVICE_ACCOUNT" \
	--project="$GOOGLE_CLOUD_PROJECT" \
	--role=roles/iam.workloadIdentityUser \
	--member="principalSet://iam.googleapis.com/projects/$PROJECT_NUMBER/locations/global/workloadIdentityPools/github-pool/attribute.repository/$GITHUB_REPO" >/dev/null

WIF_PROVIDER="projects/$PROJECT_NUMBER/locations/global/workloadIdentityPools/github-pool/providers/github-provider"

# GitHub Actions environment
gh api "repos/$GITHUB_REPO/environments/production" -X PUT >/dev/null

for pair in \
	"GOOGLE_CLOUD_WORKLOAD_IDENTITY_PROVIDER:$WIF_PROVIDER" \
	"GOOGLE_CLOUD_SERVICE_ACCOUNT:$GITHUB_ACTIONS_SERVICE_ACCOUNT" \
	"TERRAFORM_STATE_BUCKET_NAME:$TERRAFORM_STATE_BUCKET_NAME"; do
	gh secret set "${pair%%:*}" --env production --body "${pair#*:}" --repo "$GITHUB_REPO"
done

gh variable set GOOGLE_CLOUD_REGION --env production --body europe-north1 --repo "$GITHUB_REPO"

echo "Done. Run 'Deploy Ping-Home Infra' from the GitHub Actions tab to launch."
