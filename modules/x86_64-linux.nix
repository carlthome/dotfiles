{ config, pkgs, ... }: {

  # TODO Set this if not NixOS but still Linux.
  # targets.genericLinux.enable = true;

  home.packages = with pkgs; [
    caprine-bin
    chromium
    discord
    dropbox-cli
    element-desktop
    firefox
    google-chrome
    keepassxc
    marker
    obs-studio
    okular
    reaper
    signal-desktop
    slack
    spotify
    stdenv.cc.cc.lib
    steam
    tdesktop
    wineWowPackages.staging
    yabridge
    yabridgectl
  ];

  home.sessionVariables = with pkgs; {
    LD_LIBRARY_PATH = "${stdenv.cc.cc.lib}/lib:$LD_LIBRARY_PATH";
  };
}