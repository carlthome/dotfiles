# dotfiles

My personal [Home Manager](https://github.com/nix-community/home-manager) configuration that I wish to sync between machines.

## Install

1. Install `nix` on the system (with [flakes enabled](https://nixos.wiki/wiki/Flakes#Enable_flakes))
1. Add `home-manager` and `cachix` by running `nix develop github:carlthome/dotfiles`
1. (optional) Use additional binary caches by `cachix use cuda-maintainers` and `cachix use nixpkgs-unfree`
1. Create initial home configuration with `home-manager switch --flake github:carlthome/dotfiles`
1. List installed packages with `home-manager packages`

## Develop

1. Clone this flake repo to the current working directory by `nix flake clone github:carlthome/dotfiles --dest .`
1. Stage declarative changes (in [flake.nix](./flake.nix) etc.) as needed
1. Run tests with `nix flake check`
1. Switch to the new configuration by `home-manager switch --flake .`
