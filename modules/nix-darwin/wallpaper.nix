{ config, lib, pkgs, ... }: {
  options.services.wallpaper = {
    enable = lib.mkEnableOption "Automatic wallpaper changing service";

    interval = lib.mkOption {
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

  config = lib.mkIf config.services.wallpaper.enable {
    environment.systemPackages = with pkgs; [
      darwin.apple_sdk.frameworks.CoreServices
    ];

    launchd.agents.change-wallpaper = {
      serviceConfig = {
        ProgramArguments = [
          "/bin/sh"
          "-c"
          ''
            WALLPAPER_URL="https://source.unsplash.com/random/3840x2160/?${config.services.wallpaper.category}"
            WALLPAPER_PATH="/tmp/wallpaper.jpg"
            curl -L "$WALLPAPER_URL" -o "$WALLPAPER_PATH"
            osascript -e "tell application \"Finder\" to set desktop picture to POSIX file \"$WALLPAPER_PATH\""
          ''
        ];
        StartCalendarInterval = (if config.services.wallpaper.interval == "hourly"
        then [{ Minute = 0; }]
        else [{ Hour = 0; Minute = 0; }]);
        RunAtLoad = true;
        StandardErrorPath = "/tmp/change-wallpaper.err";
        StandardOutPath = "/tmp/change-wallpaper.out";
      };
    };
  };
}
