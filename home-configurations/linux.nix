{ config, pkgs, home, ... }: {
  home.packages = with pkgs;
    let python = import ./python.nix { inherit pkgs; };
    in [
      caprine-bin
      discord
      jupyter
      keepassxc
      okular
      python.env
      reaper
      signal-desktop
      steam
      tdesktop
      yabridge
      yabridgectl
    ];

  programs.firefox.enable = true;
  programs.chromium.enable = true;
  programs.obs-studio.enable = true;
}
