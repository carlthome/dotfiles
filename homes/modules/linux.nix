{ pkgs, ... }: {
  home.packages = with pkgs; [
    caprine-bin
    chromium
    dropbox-cli
    firefox
    google-chrome
    keepassxc
    marker
    obs-studio
    okular
    reaper
    signal-desktop
    steam
    tdesktop
    yabridge
    yabridgectl
    marker
  ];
}
