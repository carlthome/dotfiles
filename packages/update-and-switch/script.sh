#!/bin/sh
set -ex

# Pull remote repository.
git pull

# Update flake lock file.
nix flake update --commit-lock-file --flake .

# Check evaluation before switching.
nix flake check --all-systems

# Build default package.
nix build

# Switch home configuration.
home-manager switch --flake .

# Switch system configuration.
OS_TYPE="$(uname)"
if [ "$OS_TYPE" = "Darwin" ]; then
	sudo darwin-rebuild switch --flake .
elif [ "$OS_TYPE" = "Linux" ]; then
	sudo nixos-rebuild switch --flake .
else
	echo "Unknown OS: $OS_TYPE"
	exit 1
fi

# Update remote repository.
git push
