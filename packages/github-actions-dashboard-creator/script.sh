#!/bin/bash
set -e

user=${1:-carlthome}
repos=$(gh repo list "$user" --no-archived --visibility=public --source --json name --jq '.[] | .name')
echo "Collecting workflows from $(echo "$repos" | wc -l) repositories."

# Truncate repos
# Uncomment the line below to limit to a single repo for testing.
# repos=$(echo "$repos" | head -n 3)

# Collect build status for each workflow in each repo.
touch repos.json
echo '{"repos": [' >repos.json
for repo in $repos; do
	echo "Listing workflows for $repo"

	# List all workflows in the repo.
	workflows=$(gh workflow list --repo "$user/$repo" --json path --jq '.[].path | sub("^.github/workflows/"; "")')

	# Add a badge for each workflow.
	echo "{\"repo\": \"$repo\", \"workflows\": [" >>repos.json
	for workflow in $workflows; do
		echo "\"$workflow\", " >>repos.json
	done
	echo "]}," >>repos.json
done
echo "]}" >>repos.json

# Render the HTML template with the JSON data.
JSON_DATA=$(tr -d '\n' <repos.json)
sed "s|{{TEMPLATE_TAG}}|$JSON_DATA|g" "${TEMPLATE_PATH}" >index.html
