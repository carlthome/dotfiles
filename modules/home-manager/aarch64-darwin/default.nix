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
      ];
    permittedInsecurePackages = [
      "lima-additional-guestagents-1.2.2"
      "lima-full-1.2.2"
      "python3.12-ecdsa-0.19.1"
    ];
  };

  home.packages = with pkgs; [
    colima
    net-news-wire
    roomeqwizard
    sequelpro
    stats
    iterm2
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
