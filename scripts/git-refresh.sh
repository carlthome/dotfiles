#!/bin/sh
set -e

# Download remote changes for all git repos and check if local repo is up-to-date.
git_root="$HOME/Repos"

# Find local repos.
repos=$(find "$git_root" -print0 -name .git | xargs dirname)

printf "Will run 'git fetch' for:\n%s\n\n" "$repos"

# Go through every repo, fetch remote changes and warn on local changes not found remotely.
for repo in $repos; do
  cwd=$(pwd)
  cd "$repo"

  # Download remote changes.
  git fetch

  # Display local changes.
  status=$(git status --porcelain)
  if [ -n "$status" ]; then
    printf "%s has local changes:\n%s\n\n" "$repo" "$status"
  else
    printf "%s is up-to-date with remote\n\n" "$repo"
  fi

  cd "$cwd"
done
