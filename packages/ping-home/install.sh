#!/usr/bin/env bash
# Bootstrap helper for ping-home.
set -euo pipefail

echo "Configuring environment..."
# shellcheck source=/dev/null
source ./configure-environment.sh

echo "Creating Terraform state bucket (if it doesn't exist)..."
./create-state-bucket.sh

echo "Initializing Terraform..."
set -a
# shellcheck source=/dev/null
source .env
set +a
cd terraform/
terraform init -backend-config="bucket=$TERRAFORM_STATE_BUCKET_NAME"

if command -v gh &>/dev/null && gh auth status &>/dev/null; then
	GITHUB_TOKEN=$(gh auth token)
	echo "✓ Using GitHub token from gh cli"
else
	read -rsp "GitHub Token (for GitHub provider): " GITHUB_TOKEN
	echo
fi
export GITHUB_TOKEN

echo ""
echo "Running terraform apply..."
terraform apply -auto-approve

cd ..
echo ""
echo "Setting up GitHub App for CI..."
./create-github-app.sh

echo ""
echo "Populating application secrets..."
./populate-application-secrets.sh

echo ""
echo "✓ Setup complete!"
