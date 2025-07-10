{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.services.auto-upgrade;

  upgradeScript = pkgs.writeShellApplication {
    name = "auto-upgrade-nix-darwin";
    text = ''
      echo "Starting Nix upgrade at $(date)"
      /run/current-system/sw/bin/darwin-rebuild switch --refresh --flake ${cfg.flake}
      echo "Nix upgrade completed at $(date)"
    '';
    runtimeInputs = with pkgs; [
      coreutils
    ];
  };

  calendarIntervals = {
    "hourly" = [
      { Minute = 0; }
    ];
    "daily" = [
      {
        Hour = 0;
        Minute = 0;
      }
    ];
    "weekly" = [
      {
        Weekday = 0;
        Hour = 0;
        Minute = 0;
      }
    ];
    "monthly" = [
      {
        Day = 1;
        Hour = 0;
        Minute = 0;
      }
    ];
    "yearly" = [
      {
        Month = 1;
        Day = 1;
        Hour = 0;
        Minute = 0;
      }
    ];
  };
in
{
  options.services.auto-upgrade = {
    enable = lib.mkEnableOption "Automatic system upgrades";

    frequency = lib.mkOption {
      type = lib.types.str;
      example = "weekly";
      default = "daily";
      description = "The interval at which auto upgrade is run.";
    };

    flake = lib.mkOption {
      type = lib.types.str;
      description = "Flake URI to use for upgrades";
    };
  };

  config = lib.mkIf cfg.enable {
    launchd.daemons.auto-upgrade.serviceConfig = {
      Program = "${toString upgradeScript}/bin/${upgradeScript.name}";
      ProcessType = "Background";
      StartCalendarInterval = calendarIntervals.${cfg.frequency};
      StandardErrorPath = "/tmp/${upgradeScript.name}.err";
      StandardOutPath = "/tmp/${upgradeScript.name}.out";
      RunAtLoad = true;
    };
  };
}
