#!/bin/sh
# Example: nix-diff-flake .#nixosConfigurations.t1.pkgs.webkitgtk nixpkgs#webkitgtk
set -e

left=$1
right=$2

nix-diff "$(nix path-info --derivation "$left")" "$(nix path-info --derivation "$right")"
