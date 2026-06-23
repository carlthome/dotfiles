#!/usr/bin/env bash
# Interactive ripgrep + git blame — search code and inspect authorship
# - CTRL-T: toggle between ripgrep and fzf filtering
# - CTRL-G: show full git commit for the selected line
# - ?: toggle preview
# - Enter: open in vim at the matching line

INITIAL_QUERY="${*:-}"
RG_PREFIX="rg --line-number --no-heading --color=always --smart-case"

STATE_DIR="${TMPDIR:-/tmp}/fzf-git-blame.$$"
mkdir -p "$STATE_DIR"
trap 'rm -rf "$STATE_DIR"' EXIT

RG_QUERY="$STATE_DIR/rg-query"
FZF_QUERY="$STATE_DIR/fzf-query"

fzf --ansi --disabled --query "$INITIAL_QUERY" \
	--prompt 'rg blame> ' \
	--header '^T: rg/fzf | ^G: show commit | ^P: line history | ?: preview' \
	--color "hl:-1:underline,hl+:-1:underline:reverse" \
	--delimiter : \
	--bind "start:reload:$RG_PREFIX {q}" \
	--bind "change:reload:sleep 0.1; $RG_PREFIX {q} || true" \
	--bind "ctrl-t:transform:
      if [[ \$FZF_PROMPT =~ rg ]]; then
        echo \"unbind(change)+change-prompt(fzf blame> )+enable-search+transform-query:echo {q} > $RG_QUERY; cat $FZF_QUERY\"
      else
        echo \"rebind(change)+change-prompt(rg blame> )+disable-search+transform-query:echo {q} > $FZF_QUERY; cat $RG_QUERY\"
      fi" \
	--preview "git show --color=always \$(git blame --porcelain -L {2},{2} {1} 2>/dev/null | head -1 | cut -d' ' -f1)" \
	--preview-window 'right:60%' \
	--bind 'focus:transform-preview-label:echo {1}' \
	--bind '?:toggle-preview' \
	--bind "ctrl-g:execute:git show --color=always \$(git blame --porcelain -L {2},{2} {1} | head -1 | cut -d ' ' -f1) | less -R" \
	--bind "ctrl-p:execute:git log --color=always --follow -L {2},{2}:{1} | less -R" \
	--bind 'enter:become(vim {1} +{2})'
