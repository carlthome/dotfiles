{ pkgs, ... }: {
  type = "app";
  program = (pkgs.writeScript "update-system" ''
    set -exuo pipefail
    sudo nixos-rebuild switch --impure --flake .
    nix-env --delete-generations 30d
    nix store optimise
    nixos-version
  '').outPath;
}
