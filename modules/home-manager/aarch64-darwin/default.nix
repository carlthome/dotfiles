{
  config,
  pkgs,
  lib,
  ...
}:
{
  nixpkgs.config = {
    allowUnfreePredicate =
      pkg:
      builtins.elem (lib.getName pkg) [
        "claude-code"
        "roomeqwizard"
        "terraform"
        "vscode"
        "discord"
        "google-chrome"
        "spotify"
        "whatsapp-for-mac"
        "reaper"
      ];
  };

  home.packages = with pkgs; [
    colima
    net-news-wire
    roomeqwizard
    signal-desktop
    sequelpro
    stats
    iterm2
    discord
    element-desktop
    firefox
    google-chrome
    keepassxc
    spotify
    telegram-desktop
    whatsapp-for-mac
    reaper
    opencode-desktop
    # TODO Not supported on darwin arm64 yet
    #steam
    # TODO Not supported on darwin arm64 yet
    #chromium
    # TODO Not supported on darwin arm64 yet
    #dropbox
  ];

  # Create wrapper apps so Spotlight can find Nix-installed GUI apps.
  services.macos-spotlight-apps.enable = true;

  # Configure macOS settings.
  targets.darwin.defaults = {
    "com.apple.trackpad" = {
      Clicking = true;
    };
    "com.apple.desktopservices" = {
      DSDontWriteNetworkStores = true;
      DSDontWriteUSBStores = true;
    };
    "com.apple.dock" = {
      autohide = true;
      orientation = "bottom";
      show-process-indicators = false;
      show-recents = false;
      static-only = true;
    };
    "com.apple.finder" = {
      AppleShowAllExtensions = true;
      AppleShowAllFiles = true;
      ShowPathBar = true;
      ShowStatusBar = true;
      FXEnableExtensionChangeWarning = false;
      FXRemoveOldTrashItems = true;
    };
  };
}
