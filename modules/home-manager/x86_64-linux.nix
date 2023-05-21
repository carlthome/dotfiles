{ config, pkgs, lib, ... }: {

  # TODO Set this if not NixOS but still Linux.
  # targets.genericLinux.enable = true;

  nixpkgs.config = {
    allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
      "discord"
      "dropbox"
      "google-chrome"
      "reaper"
      "slack"
      "spotify"
      "steam-original"
      "steam"
      "vscode"
      "vscode-extension-github-copilot"
      "vscode-extension-MS-python-vscode-pylance"
      "vscode-extension-ms-vscode-cpptools"
      "vscode-extension-ms-vsliveshare-vsliveshare"
    ];
    permittedInsecurePackages = [
      "electron-20.3.11"
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
    helvum
    keepassxc
    logseq
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
    zlib
  ];

  home.sessionVariables = with pkgs; {
    # TODO Think this through better.
    # LD_LIBRARY_PATH = "${zlib}/lib:${stdenv.cc.cc.lib}/lib:$LD_LIBRARY_PATH";
  };
}
