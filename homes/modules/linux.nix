{ config, pkgs, lib, options, specialArgs, modulesPath }: {
  home.packages = with pkgs; [
    caprine-bin
    discord
    jupyter
    keepassxc
    okular
    reaper
    signal-desktop
    steam
    tdesktop
    yabridge
    yabridgectl
    marker
  ];

  programs = {
    firefox.enable = true;
    chromium.enable = true;
    obs-studio.enable = true;
  };
}
