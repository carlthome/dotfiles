{ config, pkgs, lib, ... }: {

  # TODO Set this if not NixOS but still Linux.
  # targets.genericLinux.enable = true;

  nixpkgs.config = {
    cudaSupport = true;
    cudnnSupport = true;
    allowUnfree = true;
    allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
      "cudatoolkit"
      "discord"
      "dropbox"
      "google-chrome"
      "reaper"
      "slack"
      "spotify"
      "steam-original"
      "steam"
    ];
  };

  home.packages = with pkgs; [
    caprine-bin
    chromium
    deja-dup
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
