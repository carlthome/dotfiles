#!/usr/bin/env bash

# 1. Search for text in tracked files using git grep
# 2. Interactively narrow down the list using fzf
# 3. Open the selected file in Vim at the matching line

git grep --line-number --color=always "${*:-}" |
	fzf --ansi \
		--color "hl:-1:underline,hl+:-1:underline:reverse" \
		--delimiter : \
		--preview 'bat --color=always {1} --highlight-line {2}' \
		--preview-window 'up,60%,border-bottom,+{2}+3/3,~3' \
		--bind 'enter:become(vim {1} +{2})'
