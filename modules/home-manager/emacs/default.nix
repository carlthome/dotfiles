{
  config,
  pkgs,
  lib,
  ...
}:
{
  programs.emacs = {
    # TODO Currently not working on macOS.
    enable = false;
    extraPackages =
      epkgs: with epkgs; [
        emms
        magit
      ];
  };
}
