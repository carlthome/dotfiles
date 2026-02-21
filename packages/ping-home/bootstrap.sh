#!/bin/bash
set -e

echo "🚀 Welcome to the Turn-Key Ping-Home Setup!"
echo "This will configure Workload Identity Federation and Secrets in GCP."
echo "---------------------------------------------------------------------------------"
echo "Prerequisites: gcloud auth login && gh auth login"
echo ""

# ==========================================
# PHASE 1: INTERACTIVE PROMPTS
# ==========================================
read -p "1. Enter your GCP Project ID: " GCP_PROJECT_ID
read -p "2. Enter your GitHub Repository (e.g., carlthome/dotfiles): " GITHUB_REPO
read -p "3. Enter a globally unique name for your Terraform State bucket (e.g., carlthome-tf-state): " GCS_BUCKET_NAME
echo "4. Let's configure your Secrets:"
read -p "   Enter your Home LAN Endpoint (e.g., http://192.168.1.1:8080): " HOME_LAN_ENDPOINT
read -p "   Enter your Alert Email address: " ALERT_EMAIL
read -sp "   Enter your Ephemeral Tailscale Auth Key (tskey-auth-...): " TAILSCALE_AUTH_KEY
echo ""

gcloud config set project "$GCP_PROJECT_ID"
PROJECT_NUMBER=$(gcloud projects describe "$GCP_PROJECT_ID" --format="value(projectNumber)")

# ==========================================
# PHASE 2: ENABLE APIS & CREATE BUCKET
# ==========================================
echo "🔄 Enabling bootstrap-prerequisite GCP APIs..."
# Only what's needed before Terraform can authenticate and store state.
# run, cloudscheduler, artifactregistry, and monitoring are owned by Terraform.
gcloud services enable \
  cloudresourcemanager.googleapis.com \
  iamcredentials.googleapis.com \
  secretmanager.googleapis.com \
  storage.googleapis.com

echo "🪣 Creating GCS Bucket for Terraform State..."
gcloud storage buckets create "gs://$GCS_BUCKET_NAME" --location=europe-north1 2>/dev/null || echo "   Bucket already exists, continuing..."

# ==========================================
# PHASE 3: SECRETS MANAGER
# ==========================================
echo "🔐 Pushing secrets to Google Secret Manager..."
create_gcp_secret() {
    gcloud secrets create "$1" --replication-policy="automatic" 2>/dev/null || true
    echo -n "$2" | gcloud secrets versions add "$1" --data-file=- >/dev/null
}
create_gcp_secret "home-lan-endpoint" "$HOME_LAN_ENDPOINT"
create_gcp_secret "alert-email" "$ALERT_EMAIL"
create_gcp_secret "tailscale-auth-key" "$TAILSCALE_AUTH_KEY"

# ==========================================
# PHASE 4: WORKLOAD IDENTITY FEDERATION
# ==========================================
echo "🤖 Setting up Workload Identity Federation (WIF)..."
SA_NAME="github-actions-sa"
SA_EMAIL="${SA_NAME}@${GCP_PROJECT_ID}.iam.gserviceaccount.com"

# 1. Create the Service Account and grant permissions
gcloud iam service-accounts create "$SA_NAME" --display-name="GitHub Actions Service Account" 2>/dev/null || true
gcloud projects add-iam-policy-binding "$GCP_PROJECT_ID" --member="serviceAccount:${SA_EMAIL}" --role="roles/editor" >/dev/null
gcloud projects add-iam-policy-binding "$GCP_PROJECT_ID" --member="serviceAccount:${SA_EMAIL}" --role="roles/secretmanager.secretAccessor" >/dev/null
gcloud projects add-iam-policy-binding "$GCP_PROJECT_ID" --member="serviceAccount:${SA_EMAIL}" --role="roles/iam.serviceAccountUser" >/dev/null

# 2. Create the WIF Pool
gcloud iam workload-identity-pools create "github-pool" --project="$GCP_PROJECT_ID" --location="global" --display-name="GitHub Actions Pool" 2>/dev/null || true

# 3. Create the WIF Provider (Locked securely to your specific GitHub repo)
gcloud iam workload-identity-pools providers create-oidc "github-provider" \
  --project="$GCP_PROJECT_ID" \
  --location="global" \
  --workload-identity-pool="github-pool" \
  --display-name="GitHub Provider" \
  --attribute-mapping="google.subject=assertion.sub,attribute.actor=assertion.actor,attribute.repository=assertion.repository" \
  --attribute-condition="assertion.repository == '${GITHUB_REPO}'" \
  --issuer-uri="https://token.actions.githubusercontent.com" 2>/dev/null || true

# 4. Bind the GitHub Repo to the Service Account
gcloud iam service-accounts add-iam-policy-binding "$SA_EMAIL" \
  --project="$GCP_PROJECT_ID" \
  --role="roles/iam.workloadIdentityUser" \
  --member="principalSet://iam.googleapis.com/projects/${PROJECT_NUMBER}/locations/global/workloadIdentityPools/github-pool/attribute.repository/${GITHUB_REPO}" >/dev/null

WIF_PROVIDER="projects/${PROJECT_NUMBER}/locations/global/workloadIdentityPools/github-pool/providers/github-provider"

# ==========================================
# PHASE 5: GITHUB ENVIRONMENT
# ==========================================
echo "🐙 Configuring GitHub Actions 'production' environment..."
gh api repos/"$GITHUB_REPO"/environments/production -X PUT >/dev/null

echo "   Setting secrets..."
gh secret set GCP_WORKLOAD_IDENTITY_PROVIDER --env production --body "$WIF_PROVIDER" --repo "$GITHUB_REPO"
gh secret set GCP_SERVICE_ACCOUNT --env production --body "$SA_EMAIL" --repo "$GITHUB_REPO"
gh secret set GCP_PROJECT_ID --env production --body "$GCP_PROJECT_ID" --repo "$GITHUB_REPO"
gh secret set GCS_BUCKET_NAME --env production --body "$GCS_BUCKET_NAME" --repo "$GITHUB_REPO"

echo "   Setting variables..."
gh variable set REGION --env production --body "europe-north1" --repo "$GITHUB_REPO"
gh variable set REPO_NAME --env production --body "lan-checker-repo" --repo "$GITHUB_REPO"
gh variable set SERVICE_NAME --env production --body "home-lan-checker" --repo "$GITHUB_REPO"

echo ""
echo "✅ BOOTSTRAP COMPLETE!"
echo "---------------------------------------------------------------------------------"
echo "WIF is active. No static credentials exist anywhere."
echo "Go to your GitHub Actions tab and manually run 'Deploy Ping-Home Infra' to launch!"
