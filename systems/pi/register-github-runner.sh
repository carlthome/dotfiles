#!/usr/bin/env bash
# Register the Pi as a self-hosted GitHub Actions runner for a repository, deploy it, and
# optionally route that repository's CI to it.
#
#   ./register-github-runner.sh <owner>/<repo> [options]
#
# Options:
#   --name NAME        Runner name in github-runners.nix (default: the repository name).
#   --route-var VAR    Set the repository variable VAR to the runner's label, for workflows that
#                      pick their runner with `runs-on: ${{ vars.VAR || 'ubuntu-latest' }}`.
#   --dispatch FILE    Start this workflow on the default branch once the runner is online.
#   --allow-public     Allow a public repository. Anyone who can open a pull request could then
#                      run code on the Pi, so this is off by default.
#
# Example (rustler):
#   ./register-github-runner.sh carlthome/rustler --route-var LINUX_RUNNER --dispatch test.yml
#
# Run from a machine whose SSH key the Pi already accepts, with `gh` logged in. Safe to re-run:
# every step checks whether it has already been done.
set -euo pipefail

usage() {
	sed -n '2,19p' "$0" | sed 's/^# \{0,1\}//'
	exit "${1:-0}"
}

REPO=""
NAME=""
ROUTE_VAR=""
DISPATCH=""
ALLOW_PUBLIC=false
while (($#)); do
	case $1 in
	--name)
		NAME=$2
		shift 2
		;;
	--route-var)
		ROUTE_VAR=$2
		shift 2
		;;
	--dispatch)
		DISPATCH=$2
		shift 2
		;;
	--allow-public)
		ALLOW_PUBLIC=true
		shift
		;;
	-h | --help) usage ;;
	-*)
		echo "Unknown option: $1" >&2
		usage 1
		;;
	*)
		[[ -z $REPO ]] || usage 1
		REPO=$1
		shift
		;;
	esac
done
[[ $REPO =~ ^[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+$ ]] || usage 1
OWNER=${REPO%%/*}
NAME=${NAME:-${REPO##*/}}
[[ $NAME =~ ^[A-Za-z][A-Za-z0-9-]*$ ]] || {
	echo "Runner name '$NAME' must be letters, digits and dashes; pass --name." >&2
	exit 1
}
LABEL="$NAME-pi"

PI=pi@192.168.0.2 # LAN address; port 22 is filtered on the tailnet name.
TOKEN_PATH=/etc/nixos/secrets/github-runner/$NAME.token
HERE=$(cd "$(dirname "$0")" && pwd)
DOTFILES=$(cd "$HERE/../.." && pwd)
RUNNERS_NIX=$HERE/github-runners.nix

step() { printf '\n\033[1m==> %s\033[0m\n' "$*"; }
die() {
	printf '\033[31m%s\033[0m\n' "$*" >&2
	exit 1
}

step "Preflight: $REPO as runner '$NAME' (label $LABEL)"
command -v gh >/dev/null || die "gh is not installed."
gh auth status -h github.com >/dev/null 2>&1 || die "Not logged in to GitHub: run 'gh auth login'."
read -r visibility default_branch < <(gh repo view "$REPO" --json visibility,defaultBranchRef \
	--jq '"\(.visibility) \(.defaultBranchRef.name)"') || die "Can't see $REPO with your gh login."
if [[ $visibility == PUBLIC && $ALLOW_PUBLIC != true ]]; then
	die "$REPO is public: any pull request could run code on the Pi. Pass --allow-public if you really mean it."
fi
ssh -o BatchMode=yes -o ConnectTimeout=8 "$PI" true ||
	die "Can't SSH to $PI with this machine's key. If the key is in configuration.nix but not deployed yet, run this once from a machine that already has access (e.g. t1)."
git -C "$DOTFILES" pull --ff-only
echo "OK: gh logged in, $REPO is ${visibility,,}, Pi reachable."

step "Runner entry in github-runners.nix"
if grep -Eq "^\s+$NAME = \"$REPO\";" "$RUNNERS_NIX"; then
	echo "Already listed: $NAME = \"$REPO\";"
elif grep -Eq "^\s+$NAME = " "$RUNNERS_NIX"; then
	die "'$NAME' is already used for another repository in $RUNNERS_NIX; pass --name."
else
	# Insert the entry as the first line of the `githubRunners = { ... };` attrset.
	tmp=$(mktemp)
	awk -v entry="    $NAME = \"$REPO\";" '{ print } /^\s*githubRunners = \{$/ && !done { print entry; done = 1 }' \
		"$RUNNERS_NIX" >"$tmp"
	grep -q "$NAME = \"$REPO\";" "$tmp" || {
		rm -f "$tmp"
		die "Couldn't find 'githubRunners = {' in $RUNNERS_NIX."
	}
	mv "$tmp" "$RUNNERS_NIX"
	echo "Added: $NAME = \"$REPO\"; (commit systems/pi/github-runners.nix when you're happy)"
fi

step "Fine-grained personal access token"
# shellcheck disable=SC2029 # TOKEN_PATH is deliberately expanded here, on the client.
if ssh "$PI" "sudo test -s $TOKEN_PATH"; then
	echo "A token is already installed at $TOKEN_PATH; keeping it (delete it on the Pi to replace)."
else
	# GitHub can't mint fine-grained PATs from the API, so this is the one manual step.
	url="https://github.com/settings/personal-access-tokens/new?name=$NAME-pi-runner&description=Self-hosted+Actions+runner+on+the+Pi&target_name=$OWNER&expires_in=365"
	cat <<EOF
A browser page will open. Set:
  - Resource owner:         $OWNER
  - Repository access:      Only select repositories -> $REPO
  - Repository permissions: Administration -> Read and write
Then Generate token and copy it (it starts with github_pat_).
EOF
	open "$url" 2>/dev/null || xdg-open "$url" 2>/dev/null || echo "Open: $url"

	read -rsp "Paste the token (input hidden): " token
	echo
	[[ $token == github_pat_* ]] || die "That doesn't look like a fine-grained PAT (github_pat_...)."
	GH_TOKEN=$token gh api "repos/$REPO/actions/runners" --silent ||
		die "The token can't list $REPO's runners. Check the repository selection and Administration: Read and write."

	# Sent over stdin so the token never appears in a process list or shell history.
	# shellcheck disable=SC2029 # The paths are deliberately expanded here, on the client.
	printf %s "$token" | ssh "$PI" \
		"sudo install -d -m 700 $(dirname "$TOKEN_PATH") && sudo sh -c 'umask 077 && cat > $TOKEN_PATH'"
	unset token
	echo "Token installed at $TOKEN_PATH (root-only)."
fi

step "Deploy to the Pi (nixos-rebuild test: not kept across a reboot until you switch)"
if command -v nixos-rebuild >/dev/null; then
	rebuild=(nixos-rebuild)
else
	rebuild=(nix run nixpkgs#nixos-rebuild --)
fi
(cd "$DOTFILES" && "${rebuild[@]}" --flake .#pi --fast --build-host "$PI" --target-host "$PI" --use-remote-sudo test)

step "Runner service on the Pi"
# shellcheck disable=SC2029 # NAME is deliberately expanded here, on the client.
ssh "$PI" "systemctl is-active xvfb.service github-runner-$NAME.service || true
  journalctl -u github-runner-$NAME.service -n 15 --no-pager"

step "Waiting for the runner to come online on GitHub (up to 5 minutes)"
status=""
for _ in $(seq 30); do
	status=$(gh api "repos/$REPO/actions/runners" \
		--jq ".runners[] | select(.name == \"pi\" and any(.labels[]; .name == \"$LABEL\")) | .status" 2>/dev/null || true)
	[[ $status == online ]] && break
	sleep 10
done
[[ $status == online ]] ||
	die "Runner isn't online (status: '${status:-not registered}'). Watch: ssh $PI journalctl -fu github-runner-$NAME"
echo "Runner 'pi' ($LABEL) is online for $REPO."

if [[ -n $ROUTE_VAR ]]; then
	step "Route $REPO's CI to the Pi"
	gh variable set "$ROUTE_VAR" --repo "$REPO" --body "$LABEL"
	echo "Set $ROUTE_VAR=$LABEL. Undo: gh variable delete $ROUTE_VAR --repo $REPO"
fi

if [[ -n $DISPATCH ]]; then
	step "Start $DISPATCH on $default_branch"
	gh workflow run "$DISPATCH" --repo "$REPO" --ref "$default_branch"
	sleep 20
	gh run list --repo "$REPO" --workflow "$DISPATCH" --limit 1
	echo "Watch it: gh run watch --repo $REPO"
fi

cat <<EOF

Done. Target this runner from a workflow with:
  runs-on: [self-hosted, $LABEL]

Once a job has run cleanly, make the deploy survive reboots:
  cd $DOTFILES && ${rebuild[*]} --flake .#pi --fast --build-host $PI --target-host $PI --use-remote-sudo switch
EOF
