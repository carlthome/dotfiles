{ config, pkgs, lib, ... }: {

  # TODO Set this if not NixOS but still Linux.
  # targets.genericLinux.enable = true;

  nixpkgs.config = {
    allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
      "discord"
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
      "vscode-extension-ms-vscode-remote-remote-ssh"
      "vscode-extension-ms-vsliveshare-vsliveshare"
    ];
  };

  home.packages = with pkgs; [
    caprine-bin
    chromium
    deja-dup
    discord
    maestral
    maestral-gui
    element-desktop
    firefox
    google-chrome
    helvum
    keepassxc
    logseq
    marker
    obs-studio
    okular
    peek
    reaper
    signal-desktop
    slack
    spotify
    stdenv.cc.cc.lib
    steam
    tdesktop
    transmission-gtk
    wineWowPackages.staging
    yabridge
    yabridgectl
    zlib
  ] ++ (with pkgs.gnomeExtensions;
    [
      bing-wallpaper-changer
      blur-my-shell
      caffeine
      hue-lights
      night-theme-switcher
      rounded-window-corners
    ]);

  home.sessionVariables = with pkgs; {
    # TODO Think this through better.
    # LD_LIBRARY_PATH = "${zlib}/lib:${stdenv.cc.cc.lib}/lib:$LD_LIBRARY_PATH";
  };

  # Use `dconf watch /` to track stateful changes you are doing, then set them here.
  dconf.settings = {
    "org/gnome/shell" = {
      enabled-extensions = [
        "appindicatorsupport@rgcjonas.gmail.com"
        "apps-menu@gnome-shell-extensions.gcampax.github.com"
        "BingWallpaper@ineffable-gmail.com"
        "blur-my-shell@aunetx"
        "caffeine@patapon.info"
        "hue-lights@chlumskyvaclav.gmail.com"
        "nightthemeswitcher@romainvigier.fr"
        "places-menu@gnome-shell-extensions.gcampax.github.com"
        "rounded-window-corners@yilozt"
      ];
    };
  };
}
