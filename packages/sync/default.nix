{ pkgs, self, ... }: pkgs.writeShellApplication {
  name = "sync";
  text = ''
    # Check if flake is checked out locally.
    if [[ $(nix flake show) ]]; then
      nix flake update --commit-lock-file .
      flake='.'
    else
      flake=${self}
    fi

    # Pull remote repository.
    if [[ $flake == '.' ]]; then
      git pull
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
