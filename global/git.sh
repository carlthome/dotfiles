# Download remote changes for all git repos and check if local repo is up-to-date.
function git-refresh {
  oldpwd=$(pwd)
  git_root="$HOME/git"

  # Find local repos.
  repos=$(find "$git_root" -name .git | xargs dirname)

  # Go through every repo, fetch remote changes and warn on local changes not found remotely.
  for repo in $repos; do
    pushd $repo

    # Download remote changes.
    git fetch

    # Display local changes.
    status=$(git status --porcelain)
    if [[ -n $status ]]; then
      printf "%s:\n%s\n\n" "$repo" "$status"
    fi;

    popd
  done
}

# Show current git branch on terminal prompt.
PS1='($(git branch --show-current): $(git log --oneline -n 1)) '"${PS1}"
export PS1
