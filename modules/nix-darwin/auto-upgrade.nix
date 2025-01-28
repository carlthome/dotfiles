{
  config,
  pkgs,
  lib,
  ...
}:
{
  options.services.auto-upgrade = {
    enable = lib.mkEnableOption "Automatic system upgrades";
    flake = lib.mkOption {
      type = lib.types.str;
      description = "Flake URI to use for upgrades";
    };
  };

  config = lib.mkIf config.services.auto-upgrade.enable {
    launchd.agents.auto-upgrade = {
      command = "/run/current-system/sw/bin/darwin-rebuild switch --refresh --flake ${config.services.auto-upgrade.flake}";
      serviceConfig = {
        ProcessType = "Background";
        StartCalendarInterval = [
          {
            Hour = 0;
            Minute = 0;
          }
        ];
        StandardErrorPath = "/tmp/auto-upgrade.err";
        StandardOutPath = "/tmp/auto-upgrade.out";
      };
    };
  };
}
