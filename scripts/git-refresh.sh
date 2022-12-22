#!/bin/sh
set -e

# Download remote changes for all git repos and check if local repo is up-to-date.
git_root="$HOME/git"

# Find local repos.
repos=$(find "$git_root" -0 -name .git | xargs dirname)

# Go through every repo, fetch remote changes and warn on local changes not found remotely.
for repo in $repos; do
  pushd "$repo" || return

  # Download remote changes.
  git fetch

  # Display local changes.
  status=$(git status --porcelain)
  if [[ -n $status ]]; then
    printf "%s:\n%s\n\n" "$repo" "$status"
  fi;

  popd || return
done
