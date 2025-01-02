{ config, pkgs, lib, ... }: {
  options.services.auto-upgrade = {
    enable = lib.mkEnableOption "Automatic home-manager upgrades";
    flake = lib.mkOption {
      type = lib.types.str;
      description = "Flake URI to use for upgrades";
    };
  };

  config = lib.mkIf config.services.auto-upgrade.enable {
    launchd.agents.auto-upgrade = {
      enable = true;
      config = {
        ProgramArguments = [ "${pkgs.home-manager}/bin/home-manager" "switch" "--refresh" "--flake" config.services.auto-upgrade.flake ];
        ProcessType = "Background";
        StartCalendarInterval = [{ Hour = 0; Minute = 0; }];
        StandardErrorPath = "/tmp/auto-upgrade-home.err";
        StandardOutPath = "/tmp/auto-upgrade-home.out";
      };
    };
    systemd.user = {
      timers.home-manager-auto-upgrade = {
        Unit.Description = "Home Manager upgrade timer";
        Install.WantedBy = [ "timers.target" ];
        Timer = {
          OnCalendar = "daily";
          Unit = "home-manager-auto-upgrade.service";
          Persistent = true;
        };
      };
      services.home-manager-auto-upgrade = {
        Unit.Description = "Home Manager upgrade";
        Service.ExecStart = "${pkgs.home-manager}/bin/home-manager switch --refresh --flake ${config.services.auto-upgrade.flake}";
      };
    };
  };
}
