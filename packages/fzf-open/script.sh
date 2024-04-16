#!/usr/bin/env bash
set -x
path=${1:-""}

# Run fzf to select a file.
match=$(fzf --query="$path" --no-multi --select-1 --exit-0)

if [ -z "$match" ]; then
	exit 0
elif [ -d "$match" ]; then
	echo "Opening $match in $SHELL"
	cd "$match" || exit 1
	$SHELL
elif file --mime-type -b "$match" | grep -q 'text/plain'; then
	echo "Opening $match in $EDITOR"
	$EDITOR "$match"
elif [ -f "$match" ]; then
	echo "Opening $match with default program"
	open "$match"
else
	stat "$match"
fi
