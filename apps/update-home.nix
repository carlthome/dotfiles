{ pkgs, ... }: {
  type = "app";
  program = (pkgs.writeScript "update-home" ''
    set -e
    home-manager switch --flake .#$(whoami)@${pkgs.system}
    home-manager packages
  '').outPath;
}
