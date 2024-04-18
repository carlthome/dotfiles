#!/usr/bin/env bash
command='kubectl get pods --all-namespaces'
: | fzf \
	--info=inline --layout=reverse --header-lines=1 \
	--prompt "$(kubectl config current-context | sed 's/-context$//')> " \
	--header $'╱ Enter (kubectl exec) ╱ CTRL-O (open log in editor) ╱ CTRL-R (reload) ╱\n\n' \
	--bind "start:reload:$command" \
	--bind "ctrl-r:reload:$command" \
	--bind 'ctrl-/:change-preview-window(80%,border-bottom|hidden|)' \
	--bind 'enter:execute:kubectl exec -it --namespace {1} {2} -- bash > /dev/tty' \
	--bind "ctrl-o:execute:$EDITOR <(kubectl logs --all-containers --namespace {1} {2}) > /dev/tty" \
	--preview-window up:follow \
	--preview 'kubectl logs --follow --all-containers --tail=10000 --namespace {1} {2}' "$@"
