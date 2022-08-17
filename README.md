# dotfiles

My personal [Home Manager](https://github.com/nix-community/home-manager) configuration that I wish to sync between machines.

- [home-configurations](./home-configurations) contains Home Manager configuration for my personal devices.
- [global](./global) contains .bashrc config intended to be sourced by default.
- [scripts](./scripts) contains ad-hoc scripts intended to be run on demand.

## Install

1. Install `nix` on the system
1. `git clone` repo to $HOME ([.gitignore](.gitignore) is an allowlist by design)
1. Install Home Manager with `nix profile install home-manager`

## Use

1. Make declarative changes in [flake.nix](./flake.nix)
1. Build and switch to the new configuration by `nix run`

## Develop

1. Make code changes 🤞
1. Run test jobs in [.github](.github) (e.g. run `act` or `gh workflow run`)
