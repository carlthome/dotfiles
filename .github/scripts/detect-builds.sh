#!/usr/bin/env bash
# shellcheck disable=SC2016  # Single quotes are intentional for Nix expressions
set -euo pipefail

# Determine base ref for comparison (skip comparison if not in CI)
BASE_REF=""
if [[ -n ${GITHUB_BASE_REF:-} ]]; then
	BASE_REF="github:${GITHUB_REPOSITORY}/${GITHUB_BASE_REF}"
elif [[ -n ${GITHUB_SHA:-} ]]; then
	BASE_REF="github:${GITHUB_REPOSITORY}/${GITHUB_SHA}~1"
fi

if [[ -n $BASE_REF ]]; then
	echo "Comparing against: $BASE_REF"
	echo "Pre-fetching base ref..."
	nix flake prefetch "$BASE_REF" --quiet || echo "Warning: could not prefetch base ref"
fi

# Check if derivation changed compared to base ref
# Returns 0 (true) if changed or new, 1 (false) if unchanged
drv_changed() {
	local attr="$1"

	# Skip comparison if no base ref (local dev or first commit)
	[[ -z $BASE_REF ]] && return 0

	local current_drv base_drv
	current_drv=$(nix eval --raw ".#${attr}.drvPath" 2>/dev/null) || return 0
	base_drv=$(nix eval --raw "${BASE_REF}#${attr}.drvPath" 2>/dev/null) || return 0

	[[ $current_drv != "$base_drv" ]]
}

# Detect flake systems (from packages output) for building default package
packages=$(nix eval --json .#packages --apply 'builtins.attrNames' | jq -c '[.[] | {
  system: .,
  "runs-on": (if . == "aarch64-darwin" then "macos-14"
              elif . == "x86_64-darwin" then "macos-13"
              elif . == "aarch64-linux" then null
              else "ubuntu-latest" end)
}] | map(select(."runs-on" != null))')

# Filter to only changed packages
changed_packages='[]'
for row in $(echo "$packages" | jq -c '.[]'); do
	sys=$(echo "$row" | jq -r '.system')
	if drv_changed "packages.${sys}.default"; then
		changed_packages=$(echo "$changed_packages" | jq -c ". + [$row]")
		echo "packages.${sys}.default: changed"
	else
		echo "packages.${sys}.default: unchanged, skipping"
	fi
done

echo "packages={\"include\":$changed_packages}" >>"$GITHUB_OUTPUT"

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
systems=$(echo "$nixos" "$darwin" | jq -sc 'add | map(. + {
  "runs-on": (if .system == "aarch64-darwin" then "macos-14"
              elif .system == "x86_64-darwin" then "macos-13"
              else "ubuntu-latest" end)
})')

# Filter to only changed systems
changed_systems='[]'
for row in $(echo "$systems" | jq -c '.[]'); do
	attr=$(echo "$row" | jq -r '.attr')
	name=$(echo "$row" | jq -r '.name')
	if drv_changed "$attr"; then
		changed_systems=$(echo "$changed_systems" | jq -c ". + [$row]")
		echo "${name}: changed"
	else
		echo "${name}: unchanged, skipping"
	fi
done

echo "systems={\"include\":$changed_systems}" >>"$GITHUB_OUTPUT"

# Detect home configurations for each system
homes='[]'
for sys in x86_64-linux aarch64-darwin; do
	runner=$(if [ "$sys" = "aarch64-darwin" ]; then echo "macos-14"; else echo "ubuntu-latest"; fi)
	names=$(nix eval --json ".#legacyPackages.$sys.homeConfigurations" --apply 'builtins.attrNames')
	homes=$(echo "$homes" "$names" | jq -sc --arg sys "$sys" --arg runner "$runner" '
    .[0] + [.[1][] | {system: $sys, name: ., "runs-on": $runner, attr: "legacyPackages.\($sys).homeConfigurations.\(.).activationPackage"}]
  ')
done

# Filter to only changed homes
changed_homes='[]'
for row in $(echo "$homes" | jq -c '.[]'); do
	attr=$(echo "$row" | jq -r '.attr')
	name=$(echo "$row" | jq -r '.name')
	sys=$(echo "$row" | jq -r '.system')
	if drv_changed "$attr"; then
		changed_homes=$(echo "$changed_homes" | jq -c ". + [$row]")
		echo "home ${name} (${sys}): changed"
	else
		echo "home ${name} (${sys}): unchanged, skipping"
	fi
done

echo "homes={\"include\":$(echo "$changed_homes" | jq -c)}" >>"$GITHUB_OUTPUT"

# Summary
echo ""
echo "=== Build Summary ==="
echo "Packages: $(echo "$changed_packages" | jq length)"
echo "Systems: $(echo "$changed_systems" | jq length)"
echo "Homes: $(echo "$changed_homes" | jq length)"
