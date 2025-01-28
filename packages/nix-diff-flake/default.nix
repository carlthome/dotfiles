{ pkgs, nix-diff, ... }:
pkgs.writeShellApplication {
  name = "nix-diff-flake";
  runtimeInputs = [ nix-diff ];
  text = builtins.readFile ./script.sh;
}
