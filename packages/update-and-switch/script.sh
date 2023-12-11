#!/bin/sh
set -ex

# Pull remote repository.
git pull

# Update flake lock file.
nix flake update --commit-lock-file .

# Switch system and home configuration.
nix run .#switch-system
nix run .#switch-home

# Install included packages.
nix profile install

# Update remote repository.
git push
