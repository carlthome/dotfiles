{ pkgs, ... }: {
  type = "app";
  program = (pkgs.writeScript "update-home" ''
    set -e
    profile=$(nix profile list | grep home-manager-path | head -n1 | awk '{print $4}')
    config=$(whoami)@$(hostname -s)
    home-manager build --flake .#$config
    nix profile remove $profile
    home-manager switch --flake .#$config
  '').outPath;
}
