{ pkgs, self, system, ... }: {
  type = "app";
  program = (pkgs.writeScript "update" ''
    set -exuo pipefail

    if [[ $(git rev-parse --is-inside-work-tree) ]]; then
      nix flake update --commit-lock-file .
    fi

    if [[ ${system} == "x86_64-linux" ]]; then
      nix run ${self}#switch-system
    fi

    nix run ${self}#switch-home

    nix store optimise
  '').outPath;
}
