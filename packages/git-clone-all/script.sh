#!/bin/sh
set -e

git_root="$HOME/Repos"

# List all source repos on GitHub.com for the current user.
repos=$(gh repo list --json nameWithOwner --limit 1000 --source | jq -r '.[].nameWithOwner')

# Clone all source repos that don't already exist locally.
for repo in $repos; do
	path="$git_root/$repo"
	if [ -d "$path" ]; then
		printf "Skipping %s, already exists locally\n" "$repo"
		continue
	fi
	git clone "git@github.com:$repo" "$path"
done
