#!/bin/sh
set -e

# Download remote changes for all git repos and check if local repo is up-to-date.
git_root="$HOME/Repos"

# Find local repos.
repos=$(find "$git_root" -maxdepth 4 -name .git -exec dirname {} \;)

printf "Will run 'git fetch' for:\n%s\n\n" "$repos"

# Go through every repo, fetch remote changes and warn on local changes not found remotely.
for repo in $repos; do

	# Download remote changes.
	git -C "$repo" fetch

	# Display local changes.
	status=$(git -C "$repo" status --porcelain)
	if [ -n "$status" ]; then
		printf "%s has local changes:\n%s\n\n" "$repo" "$status"
	else
		printf "%s is up-to-date with remote\n\n" "$repo"
	fi
done
