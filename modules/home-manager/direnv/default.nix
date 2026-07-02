{
  config,
  pkgs,
  lib,
  ...
}:
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
