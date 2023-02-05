# dotfiles

My personal computing configuration that I wish to sync between machines.

## Install

1. Install `nix` on the system (with [flakes enabled](https://nixos.wiki/wiki/Flakes#Enable_flakes))
1. See available packages by `nix flake show github:carlthome/dotfiles`
1. Create system and home configuration with `nix run github:carlthome/dotfiles`

## Develop

1. Clone this flake to the current working directory by `nix flake clone github:carlthome/dotfiles --dest .`
1. Stage declarative changes (in [flake.nix](./flake.nix) etc.) as needed
1. Check with `nix flake check`
1. Update and switch with `nix run`
