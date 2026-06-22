#!/usr/bin/env bash
# Interactive git log — explore commit history with drill-down navigation.
# ENTER:  go into selected commit's ancestors
# ESC:    go back to previous view (exits when at the top level)
# CTRL-G: show full commit diff in less
# ?:      toggle preview

STATE_DIR="${TMPDIR:-/tmp}/fzf-git-log.$$"
mkdir -p "$STATE_DIR"
trap 'rm -rf "$STATE_DIR"' EXIT

STACK="$STATE_DIR/stack"     # previous roots, one per line
ROOT_FILE="$STATE_DIR/root"  # current root (commit hash, branch, or empty for HEAD)
touch "$STACK"
echo "${*:-}" > "$ROOT_FILE"

# log.sh: run git log from the root stored in ROOT_FILE
cat > "$STATE_DIR/log.sh" << EOF
#!/usr/bin/env bash
root=\$(cat '$ROOT_FILE')
# shellcheck disable=SC2086
git log --color=always \\
  --format='%C(yellow)%h%C(reset) %C(auto)%d%C(reset) %s %C(dim)(%ar)%C(reset) %an' \\
  \$root
EOF
chmod +x "$STATE_DIR/log.sh"

# push.sh: push current root onto stack, set new root to $1
cat > "$STATE_DIR/push.sh" << EOF
#!/usr/bin/env bash
cat '$ROOT_FILE' >> '$STACK'
echo "\$1" > '$ROOT_FILE'
EOF
chmod +x "$STATE_DIR/push.sh"

# pop.sh: restore previous root from stack; exits 1 if stack is empty
cat > "$STATE_DIR/pop.sh" << EOF
#!/usr/bin/env bash
[ -s '$STACK' ] || exit 1
n=\$(wc -l < '$STACK')
tail -n 1 '$STACK' > '$ROOT_FILE'
head -n \$((n - 1)) '$STACK' > '$STACK.tmp'
mv '$STACK.tmp' '$STACK'
EOF
chmod +x "$STATE_DIR/pop.sh"

fzf \
  --ansi \
  --no-sort \
  --prompt 'git log> ' \
  --header 'ENTER: into commit | ESC: back | ^G: show diff | ?: preview' \
  --bind "start:reload:$STATE_DIR/log.sh" \
  --bind "enter:execute-silent($STATE_DIR/push.sh {1})+reload:$STATE_DIR/log.sh" \
  --bind "esc:transform:if $STATE_DIR/pop.sh; then echo 'reload:$STATE_DIR/log.sh'; else echo 'abort'; fi" \
  --bind "ctrl-g:execute:git show --color=always {1} | less -R" \
  --preview 'git show --color=always --stat {1}' \
  --bind 'focus:transform-preview-label:echo {1}' \
  --bind '?:toggle-preview'
