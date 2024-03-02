#!/bin/sh
set -e

# Only include repo activity for the current year.
year=$(date +%Y)

# Extract pull request information.
num_reviewed=$(gh search prs --reviewed-by=@me --created="$year" --limit=1000 --json title --jq '.[].title' | wc --lines)
num_created=$(gh search prs --author=@me --created="$year" --limit=1000 --json title --jq '.[].title' | wc --lines)
num_landed=$(gh search prs --author=@me --merged --created="$year" --limit=1000 --json title --jq '.[].title' | wc --lines)
num_involved=$(gh search prs --involves=@me --created="$year" --limit=1000 --json title --jq '.[].title' | wc --lines)

# Print results.
echo "Number of PRs reviewed: $num_reviewed"
echo "Number of PRs created: $num_created"
echo "Number of PRs landed: $num_landed"
echo "Number of PRs involved in: $num_involved"
