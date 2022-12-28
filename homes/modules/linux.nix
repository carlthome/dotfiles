{ pkgs, ... }: {

  # TODO Set this if not NixOS but still Linux.  
  # targets.genericLinux.enable = true;

  home.packages = with pkgs; [
    # TODO Stop using flatpak version.
    #discord
    caprine-bin
    chromium
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
    steam
    tdesktop
    wineWowPackages.staging
    yabridge
    yabridgectl
  ];

  home.sessionVariables = {
    LD_LIBRARY_PATH = "${pkgs.stdenv.cc.cc.lib}/lib:$LD_LIBRARY_PATH";
  };
}
