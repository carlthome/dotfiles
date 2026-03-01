#!/usr/bin/env bash
# Configure environment variables for ping-home deployment.
set -euo pipefail

# Load defaults from .env if it exists
# shellcheck source=/dev/null
[ -f .env ] && set -a && source .env && set +a

# Define configuration prompts
declare -a config_keys=(GOOGLE_CLOUD_PROJECT GOOGLE_CLOUD_REGION GITHUB_REPO TERRAFORM_STATE_BUCKET_NAME)

declare -A prompts=(
	[GOOGLE_CLOUD_PROJECT]="GCP Project ID"
	[GOOGLE_CLOUD_REGION]="GCP Region"
	[GITHUB_REPO]="GitHub Repository"
	[TERRAFORM_STATE_BUCKET_NAME]="Terraform State bucket"
)

declare -A defaults=(
	[GOOGLE_CLOUD_REGION]="europe-north1"
)

# Build .env with new/updated values
: >.env
for key in "${config_keys[@]}"; do
	current="${!key:-}"
	default="${defaults[$key]:-}"
	prompt="${prompts[$key]}"

	# Use current value if it exists, otherwise prompt
	if [ -n "$current" ]; then
		value="$current"
	else
		if [ -n "$default" ]; then
			read -rp "$prompt [$default]: " input
			value="${input:-$default}"
		else
			read -rp "$prompt: " value
		fi
	fi

	# Append to .env
	echo "$key=\"$value\"" >>.env

	# Export for this session
	export "$key=$value"
done

# Also export for gcloud
export CLOUDSDK_CORE_PROJECT="$GOOGLE_CLOUD_PROJECT"
echo "CLOUDSDK_CORE_PROJECT=\"$CLOUDSDK_CORE_PROJECT\"" >>.env

# Generate terraform.tfvars
cat >terraform/terraform.tfvars <<EOF
github_repo    = "$GITHUB_REPO"
google_project = "$GOOGLE_CLOUD_PROJECT"
google_region  = "$GOOGLE_CLOUD_REGION"
EOF
