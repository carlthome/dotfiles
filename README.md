# dotfiles

My personal computing configuration that I wish to sync between machines.

## Install

1. Install Nix on the system (with [flakes enabled](https://nixos.wiki/wiki/Flakes#Enable_flakes)) by running [bootstrap.sh](./bootstrap.sh)
1. Create system configuration with `nix run github:carlthome/dotfiles#switch-system`
1. Create user configuration with `nix run github:carlthome/dotfiles#switch-home`

## Usage

Run packages by `nix run dotfiles#<name>` where `<name>` is the package name.

Use `nix flake show dotfiles` to list all available packages.

## Develop

### Flake development

1. Clone configuration to the current working directory by `nix flake clone github:carlthome/dotfiles --dest .`
1. Stage declarative changes in [flake.nix](./flake.nix) as needed
1. Test and deploy changes with `nix run`

All systems will attempt to switch to the default branch configuration on a daily basis.

### Package development

Develop individual packages with the following commands (where `<name>` is a subdirectory in `./packages/`):

1. Enter an interactive build environment with `nix develop .#<name>` and run tests like usual (e.g. `pytest`, `cargo test`, `npm test`, etc.)
1. Run `nix develop .#<name> --command <command>` to execute a specific command within a build environment directly (for example: `nix develop .#train-mnist --command pytest` to run Python tests for the `train-mnist` package)
1. Build a package with `nix build .#<name> --print-build-logs` (view build output in the `result/` directory)
1. Temporarily install a package with `nix shell .#<name>`
1. Directly run a package's default entrypoint by `nix run .#<name>`
