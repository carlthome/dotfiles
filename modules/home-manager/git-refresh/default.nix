{ pkgs, self, ... }:
let
  program = self.packages.${pkgs.system}.git-refresh.outPath + "/bin/git-refresh";
in
{
  launchd.agents.git-refresh = {
    enable = true;
    config = {
      ProgramArguments = [ program ];
      ProcessType = "Background";
      StartCalendarInterval = [
        {
          Weekday = 0;
          Hour = 0;
          Minute = 0;
        }
      ];
      StandardErrorPath = "/tmp/git-refresh.err";
      StandardOutPath = "/tmp/git-refresh.out";
    };
  };
  systemd.user = {
    timers.git-refresh = {
      Unit.Description = "Timer for git-refresh.service";
      Install.WantedBy = [ "timers.target" ];
      Timer = {
        OnCalendar = "weekly";
        Unit = "git-refresh.service";
        Persistent = true;
      };
    };
    services.git-refresh = {
      Unit.Description = "Automatically runs git fetch for all repos";
      Service.ExecStart = program;
    };
  };
}
