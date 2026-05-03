#!/usr/bin/env bash
# shellcheck disable=SC2016  # Single quotes are intentional for Nix expressions
set -euo pipefail

START_TIME=$SECONDS

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

# Batch evaluate drvPaths for a list of attributes
# Input: JSON array of attribute paths
# Output: JSON object mapping attr -> drvPath (or null if missing)
batch_drv_paths() {
	local flake_ref="$1"
	local attrs_json="$2"

	nix eval --json "${flake_ref}" --apply "
    flake: builtins.listToAttrs (map (attr:
      let
        parts = builtins.filter (x: x != \"\") (builtins.split \"\\\\.\" attr);
        val = builtins.foldl' (acc: key: acc.\${key} or null) flake parts;
      in {
        name = attr;
        value = if val != null then val.drvPath or null else null;
      }
    ) (builtins.fromJSON ''${attrs_json}''))
  " 2>/dev/null || echo '{}'
}

# Compare current vs base drvPaths and return changed attributes
# Input: JSON array of objects with 'attr' field
# Output: filtered JSON array of changed items
filter_changed() {
	local items="$1"
	local attrs
	attrs=$(echo "$items" | jq -c '[.[].attr]')

	if [[ -z $BASE_REF ]]; then
		echo "$items"
		return
	fi

	# Evaluate current and base in parallel
	local current_file base_file
	current_file=$(mktemp)
	base_file=$(mktemp)
	trap 'rm -f "$current_file" "$base_file"' RETURN

	batch_drv_paths "." "$attrs" >"$current_file" &
	local current_pid=$!
	batch_drv_paths "$BASE_REF" "$attrs" >"$base_file" &
	local base_pid=$!

	wait "$current_pid" "$base_pid" || true

	echo "$items" | jq -c --slurpfile current "$current_file" --slurpfile base "$base_file" '
    [.[] | select(
      ($current[0][.attr] == null) or
      ($base[0][.attr] == null) or
      ($current[0][.attr] != $base[0][.attr])
    )]
  '
}

# Print what changed vs unchanged
print_status() {
	local all="$1" changed="$2" key="$3"
	echo "$all" "$changed" | jq -rs --arg key "$key" '
    (.[1] | map({(.[$key]): true}) | add // {}) as $changed |
    .[0][] | "\(.[$key]): \(if $changed[.[$key]] then "changed" else "unchanged, skipping" end)"
  '
}

echo "Gathering flake metadata..."
METADATA_START=$SECONDS

# Gather all metadata in parallel
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

# Packages (enumerate all packages per system)
nix eval --json .#packages --apply '
  pkgs: builtins.concatLists (builtins.attrValues (builtins.mapAttrs (sys: sysPkgs:
    map (name: { system = sys; name = name; attr = "packages.${sys}.${name}"; })
        (builtins.attrNames sysPkgs)
  ) pkgs))
' >"$tmpdir/packages.json" 2>/dev/null &
pid_pkg=$!

# NixOS configurations
nix eval --json .#nixosConfigurations --apply 'builtins.mapAttrs (name: cfg: {
  system = cfg.pkgs.stdenv.hostPlatform.system;
  attr = "nixosConfigurations.${name}.config.system.build.toplevel";
})' >"$tmpdir/nixos.json" 2>/dev/null &
pid_nixos=$!

# Darwin configurations
nix eval --json .#darwinConfigurations --apply 'builtins.mapAttrs (name: cfg: {
  system = cfg.pkgs.stdenv.hostPlatform.system;
  attr = "darwinConfigurations.${name}.system";
})' >"$tmpdir/darwin.json" 2>/dev/null &
pid_darwin=$!

# Home configurations (single eval for all systems)
nix eval --json .#legacyPackages --apply '
  lp: builtins.concatLists (builtins.attrValues (builtins.mapAttrs (sys: pkgs:
    if pkgs ? homeConfigurations then
      map (name: { system = sys; name = name; attr = "legacyPackages.${sys}.homeConfigurations.${name}.activationPackage"; })
          (builtins.attrNames pkgs.homeConfigurations)
    else []
  ) lp))
' >"$tmpdir/homes.json" 2>/dev/null &
pid_homes=$!

wait "$pid_pkg" "$pid_nixos" "$pid_darwin" "$pid_homes"
echo "Metadata gathered in $((SECONDS - METADATA_START))s"

# Process packages
packages=$(jq -c 'map(. + {
  "runs-on": (if .system == "aarch64-darwin" then "macos-14"
              elif .system == "x86_64-darwin" then "macos-13"
              elif .system == "aarch64-linux" then null
              else "ubuntu-latest" end)
}) | map(select(."runs-on" != null))' "$tmpdir/packages.json")

# Process systems (nixos + darwin)
systems=$(jq -sc '
  [(.[0] // {}), (.[1] // {})] | add | to_entries | map(.value + {name: .key}) | map(. + {
    "runs-on": (if .system == "aarch64-darwin" then "macos-14"
                elif .system == "x86_64-darwin" then "macos-13"
                else "ubuntu-latest" end)
  })
' "$tmpdir/nixos.json" "$tmpdir/darwin.json")

# Process homes
homes=$(jq -c 'map(. + {
  "runs-on": (if .system == "aarch64-darwin" then "macos-14"
              elif .system == "x86_64-linux" then "ubuntu-latest"
              else null end)
}) | map(select(."runs-on" != null))' "$tmpdir/homes.json")

# Filter changed items
echo ""
echo "Checking packages ($(echo "$packages" | jq length))..."
PKG_START=$SECONDS
changed_packages=$(filter_changed "$packages")
echo "$packages" "$changed_packages" | jq -rs '
  (.[1] | map({(.attr): true}) | add // {}) as $changed |
  .[0][] | "\(.name) (\(.system)): \(if $changed[.attr] then "changed" else "unchanged, skipping" end)"
'
echo "Packages checked in $((SECONDS - PKG_START))s"

echo ""
echo "Checking systems ($(echo "$systems" | jq length))..."
SYS_START=$SECONDS
changed_systems=$(filter_changed "$systems")
print_status "$systems" "$changed_systems" "name"
echo "Systems checked in $((SECONDS - SYS_START))s"

echo ""
echo "Checking homes ($(echo "$homes" | jq length))..."
HOME_START=$SECONDS
changed_homes=$(filter_changed "$homes")
# Use attr for homes since names can duplicate across systems
echo "$homes" "$changed_homes" | jq -rs '
  (.[1] | map({(.attr): true}) | add // {}) as $changed |
  .[0][] | "\(.name) (\(.system)): \(if $changed[.attr] then "changed" else "unchanged, skipping" end)"
'
echo "Homes checked in $((SECONDS - HOME_START))s"

# Output for GitHub Actions
{
	echo "packages={\"include\":$changed_packages}"
	echo "systems={\"include\":$changed_systems}"
	echo "homes={\"include\":$changed_homes}"
} >>"$GITHUB_OUTPUT"

# Summary
echo ""
echo "=== Build Summary ==="
echo "Packages: $(echo "$changed_packages" | jq length) changed"
echo "Systems: $(echo "$changed_systems" | jq length) changed"
echo "Homes: $(echo "$changed_homes" | jq length) changed"
echo "Total time: $((SECONDS - START_TIME))s"
