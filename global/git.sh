# Show current git branch on terminal prompt.
PS1='($(git branch --show-current): $(git log --oneline -n 1)) '"${PS1}"
export PS1
