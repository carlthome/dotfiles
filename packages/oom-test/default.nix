{ pkgs, perl, ... }: pkgs.writeShellApplication {
  name = "oom-test";
  runtimeInputs = [ perl ];
  text = builtins.readFile ./script.sh;
}
