{ config, pkgs, ... }: {
  home.username = "carlthome";
  home.homeDirectory = "/home/carlthome";

  home.packages = with pkgs;
    let python = import ./python.nix { inherit pkgs; };
    in [
      reaper
    ];

  programs.firefox.enable = true;
  programs.chromium.enable = true;
  programs.obs-studio.enable = true;
}
