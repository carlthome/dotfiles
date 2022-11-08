{ pkgs, ... }: {
  type = "app";
  program = (pkgs.writeScript "update-home" ''
    set -e
    home-manager switch --flake .
    home-manager packages
  '').outPath;
}
