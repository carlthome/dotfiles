# Download remote changes for all git repos and check if local repo is up-to-date.
function git-refresh {
  oldpwd=$(pwd)
  git_root="$HOME/git"

  # Find local repos.
  repos=$(find "$git_root" -name .git | xargs -0 dirname)

  for repo in $repos; do
    cd "$repo" || return

    # Download remote commits.
    git fetch

    # Display local changes.
    status=$(git status --porcelain)
    if [[ -n $status ]]; then
      printf "%s:\n%s\n\n" "$repo" "$status"
    fi;

    cd "$oldpwd" || return
  done
}
