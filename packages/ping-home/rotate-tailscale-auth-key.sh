#!/usr/bin/env bash
# Add a new Tailscale auth key version to GCP Secret Manager.
set -euo pipefail

secret_name=tailscale-auth-key
project=${GOOGLE_CLOUD_PROJECT:-${CLOUDSDK_CORE_PROJECT:-}}

if ! command -v gcloud >/dev/null 2>&1; then
	echo "Error: gcloud is required." >&2
	exit 1
fi

if [ -z "${project}" ]; then
	read -rp "GCP Project ID: " project
fi

if [ -z "${project}" ]; then
	echo "Error: GCP project ID cannot be empty." >&2
	exit 1
fi

read -rsp "New reusable, ephemeral Tailscale auth key: " auth_key
echo

if [[ ${auth_key} != tskey-auth-* ]]; then
	echo "Error: value does not look like a Tailscale auth key. Go to https://console.tailscale.com/admin/settings/keys and create one." >&2
	exit 1
fi

printf '%s' "${auth_key}" |
	gcloud secrets versions add "${secret_name}" \
		--project="${project}" \
		--data-file=- >/dev/null
unset auth_key

echo "✓ Added a new ${secret_name} version."
echo "New Cloud Run instances will use it automatically."
