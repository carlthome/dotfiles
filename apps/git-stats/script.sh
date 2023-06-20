#!/bin/sh
set -ex

# TODO Tabulate number of reviews conducted, landed PRs in a given time period.

owner='carlthome'
author='carlthome'

# List all source repos on GitHub.com for chosen owner.
repos=$(gh repo list "$owner" --json nameWithOwner --limit 1000 --source | jq -r '.[].nameWithOwner')

# Go through all repos for PRs created by chosen author.
for repo in $repos; do
	prs=$(gh pr list --author="$author" --repo="$repo")
	for pr in $prs; do
		echo $pr
	done
done
