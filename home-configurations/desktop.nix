{ config, pkgs, ... }: {
  home.username = "carl";
  home.homeDirectory = "/home/carl";

  # TODO Configure home desktop programs when I find the time.
  home.packages = with pkgs;
    let python = import ./python.nix { inherit pkgs; };
    in [
      reaper
      tdesktop
      steam
      python.env
      jupyter
      keepassxc
      signal-desktop
    ];

  programs.firefox.enable = true;
  programs.chromium.enable = true;
  programs.obs-studio.enable = true;
}