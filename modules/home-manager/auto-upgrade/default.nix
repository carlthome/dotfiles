{ pkgs, ... }:
let
  program = ((pkgs.writeShellApplication
    {
      name = "auto-upgrade";
      runtimeInputs = with pkgs; [ nix home-manager ];
      text = "home-manager switch --refresh --flake github:carlthome/dotfiles";
    }
  ).outPath + "/bin/auto-upgrade");
in
{
  launchd.agents.auto-upgrade = {
    enable = true;
    config = {
      ProgramArguments = [ program ];
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
      Service.ExecStart = program;
    };
  };
}
