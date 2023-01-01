{ pkgs, ... }: {
  type = "app";
  program = (pkgs.writeScript "update" ''
    set -exuo pipefail
    nix flake update
    nix run .#switch-system
    nix run .#switch-home
    git commit flake.lock -m "Update flake.lock"
  '').outPath;
}
