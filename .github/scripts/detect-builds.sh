#!/usr/bin/env bash
# shellcheck disable=SC2016  # Single quotes are intentional for Nix expressions
set -euo pipefail

START_TIME=$SECONDS

# Determine base ref for comparison
if [[ -z ${BASE_REF:-} ]]; then
	if [[ -n ${GITHUB_BASE_REF:-} ]]; then
		BASE_REF="github:${GITHUB_REPOSITORY}/${GITHUB_BASE_REF}"
	elif [[ -n ${GITHUB_EVENT_BEFORE:-} && ${GITHUB_EVENT_BEFORE} != "0000000000000000000000000000000000000000" ]]; then
		BASE_REF="github:${GITHUB_REPOSITORY}/${GITHUB_EVENT_BEFORE}"
	elif [[ -n ${GITHUB_SHA:-} ]]; then
		PARENT_SHA=$(git rev-parse "${GITHUB_SHA}^" 2>/dev/null) || PARENT_SHA=""
		[[ -n $PARENT_SHA ]] && BASE_REF="github:${GITHUB_REPOSITORY}/${PARENT_SHA}"
	fi
fi

if [[ -n ${BASE_REF:-} ]]; then
	echo "Comparing against: $BASE_REF"
	nix flake prefetch "$BASE_REF" --quiet || echo "Warning: could not prefetch base ref"
fi

echo "Gathering build targets..."

# Build complete matrix in one eval per category (in parallel)
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

# Packages: [{attr, name, system, runner}]
nix eval --json .#packages --apply '
  pkgs: builtins.concatLists (map (sys:
    map (name: {
      attr = "packages.${sys}.${name}";
      name = "pkg / ${name} (${sys})";
      system = sys;
    }) (builtins.attrNames pkgs.${sys})
  ) (builtins.attrNames pkgs))
' 2>/dev/null >"$tmpdir/packages.json" &

# NixOS systems
nix eval --json .#nixosConfigurations --apply '
  cfgs: map (name: {
    attr = "nixosConfigurations.${name}.config.system.build.toplevel";
    name = "sys / ${name}";
    system = cfgs.${name}.pkgs.stdenv.hostPlatform.system;
  }) (builtins.attrNames cfgs)
' 2>/dev/null >"$tmpdir/nixos.json" &

# Darwin systems
nix eval --json .#darwinConfigurations --apply '
  cfgs: map (name: {
    attr = "darwinConfigurations.${name}.system";
    name = "sys / ${name}";
    system = cfgs.${name}.pkgs.stdenv.hostPlatform.system;
  }) (builtins.attrNames cfgs)
' 2>/dev/null >"$tmpdir/darwin.json" &

# Homes
nix eval --json .#legacyPackages --apply '
  lp: builtins.concatLists (map (sys:
    if lp.${sys} ? homeConfigurations then
      map (name: {
        attr = "legacyPackages.${sys}.homeConfigurations.${name}.activationPackage";
        name = "home / ${name} (${sys})";
        system = sys;
      }) (builtins.attrNames lp.${sys}.homeConfigurations)
    else []
  ) (builtins.attrNames lp))
' 2>/dev/null >"$tmpdir/homes.json" &

wait

# Combine and add runners
# aarch64-linux uses ubuntu with QEMU, but only for system configs (not packages)
all_items=$(jq -sc 'add | map(. + {
  "runs-on": (
    if .system == "aarch64-darwin" then "macos-latest"
    elif .system == "x86_64-darwin" then "macos-13"
    elif .system == "x86_64-linux" then "ubuntu-latest"
    elif .system == "aarch64-linux" and (.attr | startswith("nixosConfigurations.")) then "ubuntu-latest"
    else null end
  )
}) | map(select(."runs-on" != null))' "$tmpdir/packages.json" "$tmpdir/nixos.json" "$tmpdir/darwin.json" "$tmpdir/homes.json")

echo "Found $(echo "$all_items" | jq length) build targets"

# Filter to changed items
if [[ -z ${BASE_REF:-} ]]; then
	matrix="$all_items"
else
	echo "Comparing derivations..."
	attrs=$(echo "$all_items" | jq -c '[.[].attr]')

	# Evaluate drvPaths directly — faster than nix build --dry-run (no substituter queries)
	mapfile -t attr_list < <(echo "$attrs" | jq -r '.[]')
	drv_items=$(printf 'f.%s.drvPath or null ' "${attr_list[@]}")

	nix eval -vv --impure --json --expr "let f = builtins.getFlake \"path:.\"; in [ ${drv_items} ]" >"$tmpdir/current.json" &
	nix eval -vv --impure --json --expr "let f = builtins.getFlake \"${BASE_REF}\"; in [ ${drv_items} ]" >"$tmpdir/base.json" &
	wait

	matrix=$(jq -sc '
		.[0] as $items | .[1] as $current | .[2] as $base |
		[$items, $current, $base] | transpose |
		map(select(.[1] != .[2]) | .[0])
	' <(echo "$all_items") "$tmpdir/current.json" "$tmpdir/base.json")
fi

# Print summary
echo ""
echo "$matrix" | jq -r '.[] | "\(.name): changed"'
echo ""
echo "=== Summary ==="
echo "Changed: $(echo "$matrix" | jq length) / $(echo "$all_items" | jq length)"
echo "Time: $((SECONDS - START_TIME))s"

# Output for GitHub Actions
if [[ -n ${GITHUB_OUTPUT:-} ]]; then
	echo "matrix={\"include\":$matrix}" >>"$GITHUB_OUTPUT"
fi
