# dotfiles
Until I learn about [home-manager](https://github.com/nix-community/home-manager) properly, this is some of my personal workstation shell configuration that I wish to sync between machines. To make it easy on myself, I'm only considering Bash.

- `global/` contains .bashrc config intended to be sourced by default.
- `scripts/` contains ad-hoc scripts intended to be run on demand.

## Install
Simply `git clone` directly with $HOME as the repo root (don't worry, [.gitignore](.gitignore) is an allowlist by design).

## Develop
1. Make changes. 🤞
1. Install a local GitHub Actions runner (https://github.com/nektos/act for example).
1. Run test workflows in [.github](.github) (e.g. run `act` or `gh workflow run` with $HOME as working directory).
