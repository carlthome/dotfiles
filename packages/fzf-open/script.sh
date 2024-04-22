#!/usr/bin/env bash

# Run fzf to select a path.
query=${1:-""}
match=$(fd --color=always | fzf --query="$query" --no-multi --ansi)
echo "Selected: $match"

# Get the MIME type of the selected path.
mimetype=$(file --mime-type -b "$match")
echo "MIME type: $mimetype"

# Open the selected path.
if [ -z "$match" ]; then
	exit 0
elif [ -d "$match" ]; then
	echo "Opening $match in $SHELL"
	cd "$match" && exec $SHELL
elif echo "$mimetype" | grep -q 'text/'; then
	echo "Opening $match in $EDITOR"
	$EDITOR "$match"
elif [ -f "$match" ]; then
	echo "Opening $match with default program"
	open "$match"
else
	stat "$match"
fi
