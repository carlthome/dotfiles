#!/usr/bin/env bash
# shellcheck disable=SC2016  # Single quotes are intentional for Nix expressions
set -euo pipefail

START_TIME=$SECONDS

# Determine base ref for comparison (skip comparison if not in CI)
# Allow BASE_REF to be passed directly for testing
if [[ -z ${BASE_REF:-} ]]; then
	if [[ -n ${GITHUB_BASE_REF:-} ]]; then
		# Pull request: compare against the target branch
		BASE_REF="github:${GITHUB_REPOSITORY}/${GITHUB_BASE_REF}"
	elif [[ -n ${GITHUB_EVENT_BEFORE:-} && ${GITHUB_EVENT_BEFORE} != "0000000000000000000000000000000000000000" ]]; then
		# Push event: compare against the previous commit (from event payload)
		BASE_REF="github:${GITHUB_REPOSITORY}/${GITHUB_EVENT_BEFORE}"
	elif [[ -n ${GITHUB_SHA:-} ]]; then
		# Fallback: resolve parent commit locally
		PARENT_SHA=$(git rev-parse "${GITHUB_SHA}^" 2>/dev/null) || PARENT_SHA=""
		if [[ -n $PARENT_SHA ]]; then
			BASE_REF="github:${GITHUB_REPOSITORY}/${PARENT_SHA}"
		fi
	fi
fi

if [[ -n ${BASE_REF:-} ]]; then
	echo "Comparing against: $BASE_REF"
	echo "Pre-fetching base ref..."
	nix flake prefetch "$BASE_REF" --quiet || echo "Warning: could not prefetch base ref"
fi

# Batch evaluate drvPaths for a list of attributes
# Input: flake ref (e.g. "." or "github:user/repo/ref") and JSON array of attribute paths
# Output: JSON object mapping attr -> drvPath (or null if missing)
batch_drv_paths() {
	local flake_ref="$1"
	local attrs_json="$2"

	# Build flake refs like ".#packages.x86_64-linux.foo" for each attr
	local refs=()
	while IFS= read -r attr; do
		refs+=("${flake_ref}#${attr}")
	done < <(echo "$attrs_json" | jq -r '.[]')

	if [[ ${#refs[@]} -eq 0 ]]; then
		echo '{}'
		return
	fi

	# Use nix build --dry-run --json to get drvPaths (preserves input order)
	local result
	result=$(nix build --dry-run --json "${refs[@]}" 2>/dev/null) || result='[]'

	# Map back to attr names (result array is in same order as input refs)
	echo "$attrs_json" "$result" | jq -sc '
		.[0] as $attrs | .[1] as $results |
		[$attrs, ($results | map(.drvPath))] |
		transpose | map({(.[0]): .[1]}) | add // {}
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
  "runs-on": (if .system == "aarch64-darwin" then "macos-latest"
              elif .system == "x86_64-darwin" then "macos-13"
              elif .system == "aarch64-linux" then null
              else "ubuntu-latest" end)
}) | map(select(."runs-on" != null))' "$tmpdir/packages.json")

# Process systems (nixos + darwin)
systems=$(jq -sc '
  [(.[0] // {}), (.[1] // {})] | add | to_entries | map(.value + {name: .key}) | map(. + {
    "runs-on": (if .system == "aarch64-darwin" then "macos-latest"
                elif .system == "x86_64-darwin" then "macos-13"
                else "ubuntu-latest" end)
  })
' "$tmpdir/nixos.json" "$tmpdir/darwin.json")

# Process homes
homes=$(jq -c 'map(. + {
  "runs-on": (if .system == "aarch64-darwin" then "macos-latest"
              elif .system == "x86_64-linux" then "ubuntu-latest"
              else null end)
}) | map(select(."runs-on" != null))' "$tmpdir/homes.json")

# Combine all items and filter changed in one batch
all_items=$(echo "$packages" "$systems" "$homes" | jq -sc 'add')
echo ""
echo "Checking all attributes ($(echo "$all_items" | jq length))..."
CHECK_START=$SECONDS

if [[ -z ${BASE_REF:-} ]]; then
	# No base ref, everything is changed
	changed_items="$all_items"
else
	# Full comparison: evaluate drvPaths for current and base
	all_attrs=$(echo "$all_items" | jq -c '[.[].attr]')

	# Evaluate current and base in parallel (single batch for all attrs)
	current_file=$(mktemp)
	base_file=$(mktemp)
	trap 'rm -f "$current_file" "$base_file"' EXIT

	batch_drv_paths "." "$all_attrs" >"$current_file" &
	current_pid=$!
	batch_drv_paths "$BASE_REF" "$all_attrs" >"$base_file" &
	base_pid=$!

	wait "$current_pid" "$base_pid" || true

	# Filter to changed items
	changed_items=$(echo "$all_items" | jq -c --slurpfile current "$current_file" --slurpfile base "$base_file" '
		[.[] | select(
			($current[0][.attr] == null) or
			($base[0][.attr] == null) or
			($current[0][.attr] != $base[0][.attr])
		)]
	')
fi

# Build lookup of changed attrs
changed_lookup=$(echo "$changed_items" | jq -c '[.[].attr] | map({(.): true}) | add // {}')

# Split back into categories and print status
changed_packages=$(echo "$packages" | jq -c --argjson changed "$changed_lookup" '[.[] | select($changed[.attr])]')
changed_systems=$(echo "$systems" | jq -c --argjson changed "$changed_lookup" '[.[] | select($changed[.attr])]')
changed_homes=$(echo "$homes" | jq -c --argjson changed "$changed_lookup" '[.[] | select($changed[.attr])]')

echo ""
echo "Packages ($(echo "$packages" | jq length)):"
echo "$packages" | jq -r --argjson changed "$changed_lookup" '
	.[] | "\(.name) (\(.system)): \(if $changed[.attr] then "changed" else "unchanged, skipping" end)"
'

echo ""
echo "Systems ($(echo "$systems" | jq length)):"
echo "$systems" | jq -r --argjson changed "$changed_lookup" '
	.[] | "\(.name): \(if $changed[.attr] then "changed" else "unchanged, skipping" end)"
'

echo ""
echo "Homes ($(echo "$homes" | jq length)):"
echo "$homes" | jq -r --argjson changed "$changed_lookup" '
	.[] | "\(.name) (\(.system)): \(if $changed[.attr] then "changed" else "unchanged, skipping" end)"
'

echo ""
echo "Checked in $((SECONDS - CHECK_START))s"

# Output for GitHub Actions
if [[ -n ${GITHUB_OUTPUT:-} ]]; then
	{
		echo "packages={\"include\":$changed_packages}"
		echo "systems={\"include\":$changed_systems}"
		echo "homes={\"include\":$changed_homes}"
	} >>"$GITHUB_OUTPUT"
fi

# Summary
echo ""
echo "=== Build Summary ==="
echo "Packages: $(echo "$changed_packages" | jq length) changed"
echo "Systems: $(echo "$changed_systems" | jq length) changed"
echo "Homes: $(echo "$changed_homes" | jq length) changed"
echo "Total time: $((SECONDS - START_TIME))s"
