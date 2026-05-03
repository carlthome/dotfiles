#!/usr/bin/env bash
# shellcheck disable=SC2016  # Single quotes are intentional for Nix expressions
set -euo pipefail

# Detect flake systems (from packages output) for building default package
packages=$(nix eval --json .#packages --apply 'builtins.attrNames' | jq -c '[.[] | {
  system: .,
  "runs-on": (if . == "aarch64-darwin" then "macos-14"
              elif . == "x86_64-darwin" then "macos-13"
              elif . == "aarch64-linux" then null
              else "ubuntu-latest" end)
}] | map(select(."runs-on" != null))')

echo "packages={\"include\":$packages}" >>"$GITHUB_OUTPUT"
echo "Detected flake systems for packages:"
echo "$packages" | jq .

# Detect NixOS configurations
nixos=$(nix eval --json .#nixosConfigurations --apply 'builtins.mapAttrs (name: cfg: {
  system = cfg.pkgs.stdenv.hostPlatform.system;
  attr = "nixosConfigurations.${name}.config.system.build.toplevel";
})' | jq -c '[to_entries[] | .value + {name: .key}]')

# Detect Darwin configurations
darwin=$(nix eval --json .#darwinConfigurations --apply 'builtins.mapAttrs (name: cfg: {
  system = cfg.pkgs.stdenv.hostPlatform.system;
  attr = "darwinConfigurations.${name}.system";
})' | jq -c '[to_entries[] | .value + {name: .key}]')

# Combine and add runner mapping
systems=$(echo "$nixos" "$darwin" | jq -s 'add | map(. + {
  "runs-on": (if .system == "aarch64-darwin" then "macos-14"
              elif .system == "x86_64-darwin" then "macos-13"
              else "ubuntu-latest" end)
})')

echo "systems={\"include\":$systems}" >>"$GITHUB_OUTPUT"
echo "Detected systems:"
echo "$systems" | jq .

# Detect home configurations for each system
homes='[]'
for sys in x86_64-linux aarch64-darwin; do
	runner=$(if [ "$sys" = "aarch64-darwin" ]; then echo "macos-14"; else echo "ubuntu-latest"; fi)
	names=$(nix eval --json ".#legacyPackages.$sys.homeConfigurations" --apply 'builtins.attrNames')
	homes=$(echo "$homes" "$names" | jq -s --arg sys "$sys" --arg runner "$runner" '
    .[0] + [.[1][] | {system: $sys, name: ., "runs-on": $runner, attr: "legacyPackages.\($sys).homeConfigurations.\(.).activationPackage"}]
  ')
done

echo "homes={\"include\":$(echo "$homes" | jq -c)}" >>"$GITHUB_OUTPUT"
echo "Detected homes:"
echo "$homes" | jq .
