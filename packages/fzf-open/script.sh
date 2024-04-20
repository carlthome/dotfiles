#!/usr/bin/env bash
set -x
# Run fzf to select a path.
query=${1:-""}
match=$(fd --color=always | fzf --query="$query" --no-multi --ansi)
echo "Selected: $match"

# Open the selected path.
if [ -z "$match" ]; then
	exit 0
elif [ -d "$match" ]; then
	echo "Opening $match in $SHELL"
	cd "$match" || exit 1
	exec $SHELL
elif file --mime-type -b "$match" | grep -q 'text/plain'; then
	echo "Opening $match in $EDITOR"
	$EDITOR "$match"
elif [ -f "$match" ]; then
	echo "Opening $match with default program"
	open "$match"
else
	stat "$match"
fi
