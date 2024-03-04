{ pkgs, ... }: {
  # Auto-upgrade macOS hosts periodically.
  launchd.agents.auto-upgrade = {
    command = "/run/current-system/sw/bin/darwin-rebuild switch --refresh --flake github:carlthome/dotfiles";
    serviceConfig = {
      ProcessType = "Background";
      StartCalendarInterval = [{ Hour = 0; Minute = 0; }];
      StandardErrorPath = "/tmp/auto-upgrade.err";
      StandardOutPath = "/tmp/auto-upgrade.out";
    };
  };
}
