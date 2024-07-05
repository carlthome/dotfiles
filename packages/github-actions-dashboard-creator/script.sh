#!/bin/bash
set -ex

user=carlthome
repos=$(gh repo list --source --json name --jq '.[].name')

# Collect build status for each workflow in each repo.
touch body.txt
for repo in $repos; do
	echo "Listing workflows for $repo"

	# Add a header for the repo.
	echo "<h2>$repo</h2>" >>body.txt

	# List all workflows in the repo.
	workflows=$(gh workflow list --repo "$repo" --json path --jq '.[].path | sub("^.github/workflows/"; "")')

	# Add a badge for each workflow.
	for workflow in $workflows; do
		echo "<img src=\"https://github.com/$user/$repo/actions/workflows/$workflow/badge.svg\" />" >>body.txt
	done
done

# Replace the placeholder with the actual content.
sed -i 's|{{body}}|'"$(cat body.txt)"'|' template.html >index.html
