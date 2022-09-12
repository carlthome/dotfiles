# Download remote changes for all git repos and check if local repo is up-to-date.
function git-refresh {
  git_root="$HOME/git"

  # Find local repos.
  repos=$(find "$git_root" -0 -name .git | xargs dirname)

  # Go through every repo, fetch remote changes and warn on local changes not found remotely.
  for repo in $repos; do
    pushd "$repo" || return

    # Download remote changes.
    git fetch

    # Display local changes.
    status=$(git status --porcelain)
    if [[ -n $status ]]; then
      printf "%s:\n%s\n\n" "$repo" "$status"
    fi;

    popd || return
  done
}

# Show current git branch on terminal prompt.
PS1='$(git -c color.ui=always status --short)\n($(git -c color.ui=always log --decorate --oneline -n 1))\n($(git branch --show-current)) '"${PS1}"
export PS1
