#!/bin/bash
set -x

# Install Nix.
sh <(curl -L https://nixos.org/nix/install) --daemon

# Enable flakes and the new command-line interface.
mkdir -p ~/.config/nix
echo "experimental-features = nix-command flakes" | tee ~/.config/nix/nix.conf
