{ pkgs, self, ... }: {
  type = "app";
  program = (pkgs.writeScript "switch-system" ''
    set -exuo pipefail
    sudo nixos-rebuild switch --flake ${self}
    nix-env --delete-generations 30d
    nixos-version
  '').outPath;
}
