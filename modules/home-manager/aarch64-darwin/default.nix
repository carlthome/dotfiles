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
        "roomeqwizard"
        "terraform"
        "vscode"
      ];
    permittedInsecurePackages = [
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

  # TODO Make sure applications show up on cmd+space on macOS.
  # home.activation = {
  #   copyApplications = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
  #     src="$genProfilePath/home-path/Applications/"
  #     dst="${config.home.homeDirectory}/Applications/Home Manager Trampolines"
  #     mkdir -p "$dst"
  #     ${pkgs.rsync}/bin/rsync --archive --checksum --copy-unsafe-links --delete "$src" "$dst"
  #     chmod -R 755 "$dst"
  #   '';
  # };

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
