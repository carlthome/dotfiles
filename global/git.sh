# Show current git branch on terminal prompt.
PS1=' \[\e[1;35m\]($(git branch --show-current): $(git log --oneline -n 1))\033[00m\] '"${PS1}"
export PS1
