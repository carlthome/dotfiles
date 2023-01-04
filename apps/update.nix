{ pkgs, self, system, ... }: {
  type = "app";
  program = (pkgs.writeScript "update" ''
    set -exuo pipefail

    nix flake update --commit-lock-file .

    if [[ ${system} == "x86_64-linux" ]]; then
      nix run ${self}#switch-system
    fi

    nix run ${self}#switch-home

    nix store optimise
  '').outPath;
}
