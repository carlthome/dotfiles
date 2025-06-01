{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.wallpaper;

  script = pkgs.writeShellApplication {
    name = "change-wallpaper";
    text = builtins.readFile ./wallpaper.sh;
    runtimeInputs = with pkgs; [
      curl
      jq
    ];
  };

  calendarIntervals = {
    daily = [
      {
        Hour = 0;
        Minute = 0;
      }
    ];
    hourly = [
      {
        Minute = 0;
      }
    ];
  };

in
{
  options.services.wallpaper = {
    enable = lib.mkEnableOption "Automatic wallpaper changing service";

    frequency = lib.mkOption {
      type = lib.types.str;
      default = "daily";
      description = "How often to change the wallpaper (daily, hourly)";
    };

    category = lib.mkOption {
      type = lib.types.str;
      default = "nature";
      description = "Category of images to fetch from Unsplash";
    };
  };

  config = lib.mkIf cfg.enable {
    launchd.agents.change-wallpaper = {
      serviceConfig = {
        Program = "${toString script}/bin/${script.name}";
        ProcessType = "Background";
        StartCalendarInterval = calendarIntervals.${cfg.frequency};
        StandardErrorPath = "/tmp/change-wallpaper.err";
        StandardOutPath = "/tmp/change-wallpaper.out";
      };
    };
  };
}
