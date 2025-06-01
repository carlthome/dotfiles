{
  config,
  pkgs,
  lib,
  ...
}:
{

  # TODO Set this if not NixOS but still Linux.
  # targets.genericLinux.enable = true;

  nixpkgs.config = {
    allowUnfreePredicate =
      pkg:
      builtins.elem (lib.getName pkg) [
        "discord"
        "dropbox"
        "google-chrome"
        "reaper"
        "slack"
        "spotify"
        "steam-original"
        "steam"
        "steam-unwrapped"
        "vscode"
        "terraform"
      ];
    permittedInsecurePackages = [
      "electron-28.3.3"
      "electron-27.3.11"
    ];
  };

  home.shellAliases = {
    open = "xdg-open";
  };

  home.packages =
    with pkgs;
    [
      caprine-bin
      chromium
      deja-dup
      discord
      distrobox
      dropbox
      element-desktop
      firefox
      google-chrome
      helvum
      keepassxc
      logseq
      marker
      obs-studio
      peek
      reaper
      signal-desktop
      slack
      spotify
      stdenv.cc.cc.lib
      steam
      tdesktop
      transmission_4-gtk
      wineWowPackages.full
      yabridge
      yabridgectl
      zlib
    ]
    ++ (with pkgs.gnomeExtensions; [
      bing-wallpaper-changer
      blur-my-shell
      caffeine
      hue-lights
      night-theme-switcher
      system-monitor
      vitals
    ]);

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
        "system-monitor@gnome-shell-extensions.gcampax.github.com"
        "Vitals@CoreCoding.com"
      ];
    };
  };
}
