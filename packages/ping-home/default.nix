{ pkgs, ... }:
pkgs.writeShellApplication {
  name = "ping-home";
  runtimeInputs = [
    pkgs.google-cloud-sdk
    pkgs.gh
  ];
  text = builtins.readFile ./bootstrap.sh;
}
