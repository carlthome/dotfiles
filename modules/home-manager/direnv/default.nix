{
  config,
  pkgs,
  lib,
  self,
  ...
}@inputs:
let
  system = pkgs.stdenv.hostPlatform.system;
in
{
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    config = {
      global.hide_env_diff = true;
      global.strict_env = true;
    };
    stdlib = builtins.readFile ./.direnvrc;
  };
}
