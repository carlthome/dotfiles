{ pkgs, self, ... }: pkgs.writeShellApplication {
  name = "update-and-switch";
  text = ''
    set -e

    # Check if flake is checked out locally.
    if [[ $(nix flake show) ]]; then
      nix flake update --commit-lock-file .
      flake='.'
    else
      flake=${self}
    fi

    # Switch system and home configuration.
    nix run $flake#switch-system
    nix run $flake#switch-home

    # Update remote repository.
    if [[ $flake == '.' ]]; then
      git push
    fi
  '';
}
