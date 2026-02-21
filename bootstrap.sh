#!/bin/bash
set -e

echo "🚀 Welcome to the Turn-Key Ping-Home Setup!"
echo "This will configure Workload Identity Federation, Secrets, and generate your files."
echo "---------------------------------------------------------------------------------"

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
echo "🔄 Enabling necessary GCP APIs..."
gcloud services enable \
  secretmanager.googleapis.com \
  storage.googleapis.com \
  run.googleapis.com \
  cloudscheduler.googleapis.com \
  artifactregistry.googleapis.com \
  monitoring.googleapis.com \
  iamcredentials.googleapis.com \
  cloudresourcemanager.googleapis.com

echo "🪣 Creating GCS Bucket for Terraform State..."
gcloud storage buckets create "gs://$GCS_BUCKET_NAME" --location=us-central1 2>/dev/null || echo "   Bucket already exists, continuing..."

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
# PHASE 5: GITHUB SECRETS
# ==========================================
echo "🐙 Pushing WIF configuration to GitHub Secrets..."
gh secret set GCP_WORKLOAD_IDENTITY_PROVIDER --body "$WIF_PROVIDER" --repo "$GITHUB_REPO"
gh secret set GCP_SERVICE_ACCOUNT --body "$SA_EMAIL" --repo "$GITHUB_REPO"
gh secret set GCP_PROJECT_ID --body "$GCP_PROJECT_ID" --repo "$GITHUB_REPO"

# ==========================================
# PHASE 6: FILE GENERATION
# ==========================================
echo "📝 Generating Repository Files..."
mkdir -p .github/workflows packages/ping-home/app packages/ping-home/terraform

# --- APP CI/CD WORKFLOW ---
cat << EOF > .github/workflows/ping-home-app.yml
name: Deploy Ping-Home App (Cloud Run)
on:
  push:
    branches: [ main ]
    paths: [ 'packages/ping-home/app/**' ]
  workflow_dispatch:
env:
  PROJECT_ID: \${{ secrets.GCP_PROJECT_ID }}
  REGION: "us-central1"
  REPO_NAME: "lan-checker-repo"
  SERVICE_NAME: "home-lan-checker"
jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      id-token: write  # REQUIRED FOR WIF OIDC
    steps:
      - uses: actions/checkout@v4
      - uses: google-github-actions/auth@v2
        with:
          workload_identity_provider: '\${{ secrets.GCP_WORKLOAD_IDENTITY_PROVIDER }}'
          service_account: '\${{ secrets.GCP_SERVICE_ACCOUNT }}'
      - uses: docker/setup-buildx-action@v3
      - uses: docker/login-action@v3
        with:
          registry: \${{ env.REGION }}-docker.pkg.dev
          username: oauth2accesstoken
          password: \${{ env.GOOGLE_GHA_CREDS_TOKEN }} # Auto-populated by the auth action
      - uses: docker/build-push-action@v5
        with:
          context: packages/ping-home/app
          push: true
          tags: \${{ env.REGION }}-docker.pkg.dev/\${{ env.PROJECT_ID }}/\${{ env.REPO_NAME }}/lan-checker:\${{ github.sha }}
      - uses: google-github-actions/deploy-cloudrun@v2
        with:
          service: \${{ env.SERVICE_NAME }}
          region: \${{ env.REGION }}
          image: \${{ env.REGION }}-docker.pkg.dev/\${{ env.PROJECT_ID }}/\${{ env.REPO_NAME }}/lan-checker:\${{ github.sha }}
EOF

# --- INFRA TERRAFORM WORKFLOW ---
cat << EOF > .github/workflows/ping-home-infra.yml
name: Deploy Ping-Home Infra (Terraform)
on:
  workflow_dispatch:
env:
  PROJECT_ID: \${{ secrets.GCP_PROJECT_ID }}
  REGION: "us-central1"
jobs:
  terraform:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      id-token: write  # REQUIRED FOR WIF OIDC
    defaults:
      run:
        working-directory: packages/ping-home/terraform
    steps:
      - uses: actions/checkout@v4
      - uses: google-github-actions/auth@v2
        with:
          workload_identity_provider: '\${{ secrets.GCP_WORKLOAD_IDENTITY_PROVIDER }}'
          service_account: '\${{ secrets.GCP_SERVICE_ACCOUNT }}'
      - uses: hashicorp/setup-terraform@v3
      - run: terraform init
      - run: terraform plan -out=tfplan
        env:
          TF_VAR_project_id: \${{ env.PROJECT_ID }}
          TF_VAR_region: \${{ env.REGION }}
      - run: terraform apply -auto-approve tfplan
EOF

# --- PYTHON FILES ---
cat << 'EOF' > packages/ping-home/app/Dockerfile
FROM python:3.10-slim
RUN apt-get update && apt-get install -y curl
RUN curl -fsSL https://tailscale.com/install.sh | sh
WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY . .
RUN chmod +x start.sh
CMD ["./start.sh"]
EOF

cat << 'EOF' > packages/ping-home/app/start.sh
#!/bin/bash
tailscaled --tun=userspace-networking --socks5-server=localhost:1055 &
sleep 2
tailscale up --authkey=${TAILSCALE_AUTH_KEY} --hostname=gcp-health-checker --accept-routes
exec gunicorn --bind :8080 --workers 1 --threads 8 --timeout 0 main:app
EOF

cat << 'EOF' > packages/ping-home/app/requirements.txt
Flask==3.*
gunicorn==21.*
requests[socks]==2.*
EOF

cat << 'EOF' > packages/ping-home/app/main.py
import os
import requests
from flask import Flask

app = Flask(__name__)

@app.route("/", methods=["GET", "POST"])
def check_home_lan():
    home_endpoint = os.environ.get("HOME_LAN_ENDPOINT")
    proxies = {"http": "socks5h://localhost:1055", "https": "socks5h://localhost:1055"}
    try:
        response = requests.get(home_endpoint, proxies=proxies, timeout=10)
        response.raise_for_status()
        return "Home LAN is UP", 200
    except Exception as e:
        print(f"ERROR: Home LAN Health check failed: {str(e)}")
        return f"Failed: {str(e)}", 500

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
EOF

# --- TERRAFORM FILES ---
cat << EOF > packages/ping-home/terraform/main.tf
terraform {
  backend "gcs" {
    bucket = "${GCS_BUCKET_NAME}" # Dynamically injected!
    prefix = "terraform/ping-home/state"
  }
  required_providers {
    google = { source = "hashicorp/google", version = "~> 5.0" }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_artifact_registry_repository" "repo" {
  location      = var.region
  repository_id = "lan-checker-repo"
  description   = "Docker repository for the Home LAN Checker"
  format        = "DOCKER"
}

resource "google_cloud_run_v2_service" "checker" {
  name     = "home-lan-checker"
  location = var.region
  template {
    containers {
      image = "us-docker.pkg.dev/cloudrun/container/hello"
      env {
        name = "HOME_LAN_ENDPOINT"
        value_source { secret_key_ref { secret = "home-lan-endpoint", version = "latest" } }
      }
      env {
        name = "TAILSCALE_AUTH_KEY"
        value_source { secret_key_ref { secret = "tailscale-auth-key", version = "latest" } }
      }
    }
  }
  lifecycle { ignore_changes = [template[0].containers[0].image] }
}

resource "google_cloud_scheduler_job" "cron" {
  name             = "trigger-lan-check"
  description      = "Pings the home LAN every 5 minutes"
  schedule         = "*/5 * * * *"
  time_zone        = "UTC"
  attempt_deadline = "30s"
  http_target {
    http_method = "GET"
    uri         = google_cloud_run_v2_service.checker.uri
    oidc_token { service_account_email = google_cloud_run_v2_service.checker.service_account_email }
  }
}
EOF

cat << 'EOF' > packages/ping-home/terraform/alerts.tf
data "google_secret_manager_secret_version" "email" {
  secret  = "alert-email"
  project = var.project_id
}

resource "google_monitoring_notification_channel" "email" {
  display_name = "Home LAN Alerts"
  type         = "email"
  labels = { email_address = data.google_secret_manager_secret_version.email.secret_data }
}

resource "google_monitoring_alert_policy" "lan_down" {
  display_name = "Home LAN is DOWN"
  combiner     = "OR"
  conditions {
    display_name = "Function Exception Logged"
    condition_matched_log {
      filter = "resource.type=\"cloud_run_revision\" AND resource.labels.service_name=\"${google_cloud_run_v2_service.checker.name}\" AND severity>=ERROR"
    }
  }
  notification_channels = [google_monitoring_notification_channel.email.name]
  alert_strategy {
    notification_rate_limit { period = "3600s" }
  }
}
EOF

cat << 'EOF' > packages/ping-home/terraform/variables.tf
variable "project_id" { type = string }
variable "region" { type = string, default = "us-central1" }
EOF

echo "✅ BOOTSTRAP COMPLETE!"
echo "---------------------------------------------------------------------------------"
echo "Your infrastructure is ready. WIF is active. All files are generated."
echo "Commit these files to 'main', then go to your GitHub Actions tab"
echo "and manually run 'Deploy Ping-Home Infra' to launch!"
