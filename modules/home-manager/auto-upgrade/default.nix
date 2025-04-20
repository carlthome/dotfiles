{
  config,
  pkgs,
  lib,
  ...
}:

let

  cfg = config.services.auto-upgrade;

  upgradeScript = pkgs.writeShellApplication {
    name = "auto-upgrade-home-manager";
    text = ''
      echo "Starting Home Manager upgrade at $(date)"
      home-manager switch --refresh --flake ${cfg.flake}
      echo "Home Manager upgrade completed at $(date)"
    '';
    runtimeInputs = with pkgs; [
      home-manager
      nix
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
  options = {
    services.auto-upgrade = {
      enable = lib.mkEnableOption "Periodically updates Nix configuration";

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
  };

  config =
    let
      systemdConfig = {
        systemd.user = {
          timers.home-manager-auto-upgrade = {
            Unit.Description = "Home Manager upgrade timer";
            Install.WantedBy = [ "timers.target" ];
            Timer = {
              OnCalendar = cfg.frequency;
              Unit = "${upgradeScript.name}.service";
              Persistent = true;
            };
          };
          services.home-manager-auto-upgrade = {
            Unit.Description = "Home Manager upgrade";
            Service.ExecStart = "${toString upgradeScript}/bin/${upgradeScript.name}";
          };
        };
      };
      launchdConfig = {
        launchd.agents.auto-upgrade = {
          enable = true;
          config = {
            Program = "${toString upgradeScript}/bin/${upgradeScript.name}";
            ProcessType = "Background";
            StartCalendarInterval = calendarIntervals.${cfg.frequency};
            StandardErrorPath = "/tmp/${upgradeScript.name}.err";
            StandardOutPath = "/tmp/${upgradeScript.name}.out";
          };
        };
      };
    in
    lib.mkIf cfg.enable (launchdConfig // systemdConfig);
}
