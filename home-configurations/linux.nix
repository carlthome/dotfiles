{ config, pkgs, lib, options, specialArgs, modulesPath }: {
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

  programs = {
    firefox.enable = true;
    chromium.enable = true;
    obs-studio.enable = true;
  };
}
