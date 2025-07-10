{ pkgs, ... }:

let
  template = pkgs.writeText "template.html" (builtins.readFile ./template.html);
  script = builtins.readFile ./script.sh;
in
pkgs.writeShellApplication {
  name = "github-actions-dashboard-creator";
  runtimeInputs = [
    pkgs.gh
    pkgs.gnused
  ];
  text = ''
    export TEMPLATE_PATH=${template}
    ${script}
  '';
}
