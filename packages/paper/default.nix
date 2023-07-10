{ pkgs, pdfgrep, gnused, ... }: pkgs.writeShellApplication {
  name = "paper";
  runtimeInputs = [ pdfgrep gnused ];
  text = builtins.readFile ./script.sh;
}
