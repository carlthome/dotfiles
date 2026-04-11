#!/usr/bin/env bash
# Interactive ripgrep + fzf for large codebases
# - Lazy execution: ripgrep runs on-demand as you type
# - Mode switching: CTRL-T toggles between ripgrep and fzf filtering
# - View switching: CTRL-G toggles between lines and files view

INITIAL_QUERY="${*:-}"
RG_LINES="rg --line-number --no-heading --color=always --smart-case"
RG_FILES="rg --files-with-matches --color=always --smart-case"

# Create temp directory for state
STATE_DIR="${TMPDIR:-/tmp}/rg-fzf.$$"
mkdir -p "$STATE_DIR"
trap 'rm -rf "$STATE_DIR"' EXIT

RG_QUERY="$STATE_DIR/rg-query"
FZF_QUERY="$STATE_DIR/fzf-query"

fzf --ansi --disabled --query "$INITIAL_QUERY" \
	--prompt 'rg lines> ' \
	--header '^T: rg/fzf | ^G: lines/files | ?: preview' \
	--color "hl:-1:underline,hl+:-1:underline:reverse" \
	--delimiter : \
	--bind "start:reload:$RG_LINES {q}" \
	--bind "change:reload:sleep 0.1; $RG_LINES {q} || true" \
	--bind "ctrl-t:transform:
      if [[ \$FZF_PROMPT =~ rg ]]; then
        [[ \$FZF_PROMPT =~ files ]] && p='fzf files> ' || p='fzf lines> ';
        echo \"unbind(change)+change-prompt(\$p)+enable-search+transform-query:echo {q} > $RG_QUERY; cat $FZF_QUERY\"
      else
        [[ \$FZF_PROMPT =~ files ]] && p='rg files> ' || p='rg lines> ';
        echo \"rebind(change)+change-prompt(\$p)+disable-search+transform-query:echo {q} > $FZF_QUERY; cat $RG_QUERY\"
      fi" \
	--bind "ctrl-g:transform:
      [[ \$FZF_PROMPT =~ rg ]] && m=rg || m=fzf;
      if [[ \$FZF_PROMPT =~ files ]]; then
        echo \"change-prompt(\$m lines> )+reload($RG_LINES {q})\"
      else
        echo \"change-prompt(\$m files> )+reload($RG_FILES {q})\"
      fi" \
	--preview 'BAT_THEME=ansi bat --color=always {1} --highlight-line {2} --style=plain' \
	--preview-window '+{2}+3/3,~3' \
	--bind 'focus:transform-preview-label:echo {1}' \
	--bind '?:toggle-preview' \
	--bind 'enter:become(vim {1} +{2})'
