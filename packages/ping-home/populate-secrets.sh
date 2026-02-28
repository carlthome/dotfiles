#!/usr/bin/env bash
# Populate GCP secret values for ping-home.
set -euo pipefail

if [[ $- == *x* ]]; then
	echo "Error: xtrace (set -x) is enabled. Disable it before running this script to avoid leaking secrets." >&2
	exit 1
fi

read -rp "GCP Project ID: " GOOGLE_CLOUD_PROJECT
export GOOGLE_CLOUD_PROJECT CLOUDSDK_CORE_PROJECT="$GOOGLE_CLOUD_PROJECT"

# Get all secrets from GCP (that don't have a version yet).
secrets=$(gcloud secrets list --format='value(name)')

if [ -z "$secrets" ]; then
	echo "No secrets found. Run terraform apply first."
	exit 1
fi

# Populate each secret interactively (all sensitive).
while IFS= read -r name; do
	# Check if secret already has a version
	if gcloud secrets versions list "$name" --limit=1 >/dev/null 2>&1; then
		echo "⊘ Skipping $name (already has a value)"
		continue
	fi

	read -rsp "$name: " value
	echo
	printf "%s" "$value" | gcloud secrets versions add "$name" --data-file=- >/dev/null
	echo "✓ Updated $name"
done <<<"$secrets"

echo "Done."
