# dotfiles

My personal computing configuration that I wish to sync between machines.

## Install

1. Install `nix` on the system (with [flakes enabled](https://nixos.wiki/wiki/Flakes#Enable_flakes)) by running [bootstrap.sh](./bootstrap.sh)
1. Create system configuration with `nix run github:carlthome/dotfiles#switch-system`
1. Create user configuration with `nix run github:carlthome/dotfiles#switch-home`

## Usage

Run installed packages by `nix run self#<name>` where `<name>` is the package name.

Use `nix flake show self` to list all installed packages.

## Develop

1. Clone this flake to the current working directory by `nix flake clone github:carlthome/dotfiles --dest .`
1. Stage declarative changes (in [flake.nix](./flake.nix) etc.) as needed
1. Lint source with `nix flake check`
1. Build all packages with `nix build`
1. Apply changes with `nix run .#update-and-switch` which will:
   1. Pull currently tracked remote branch
   1. Update flake inputs and commit any flake.lock changes
   1. Build and switch system configuration
   1. Build and switch user configuration
   1. Install all included utility scripts
   1. Push flake.lock to currently tracked remote branch (if previous steps succeeded)
