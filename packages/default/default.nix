{ pkgs, self, ... }: pkgs.writeScriptBin "update-and-switch" ''
  set -exuo pipefail

  if [[ $(nix flake show) ]]; then
    nix flake update --commit-lock-file .
    flake='.'
  else
    flake=${self}
  fi

  nix run $flake#switch-system
  nix run $flake#switch-home
''
