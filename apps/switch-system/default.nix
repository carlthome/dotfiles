{ pkgs, self, ... }: {
  type = "app";
  program = (pkgs.writeScript "switch-system" ''
    set -exuo pipefail
    if [[ ${pkgs.system} == "x86_64-linux" ]]; then
      sudo nixos-rebuild switch --flake ${self}
      nix-env --delete-generations 30d
      nixos-version
    fi
  '').outPath;
}
