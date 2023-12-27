{ config, pkgs, lib, ... }: {
  programs.emacs = {
    enable = true;
    extraPackages = epkgs: with epkgs; [
      emms
      magit
    ];
  };
}
