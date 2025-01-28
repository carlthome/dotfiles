{ pkgs, ... }:
let
  program = (
    (pkgs.writeShellApplication {
      name = "auto-audit";
      runtimeInputs = with pkgs; [ lynis ];
      text = "lynis audit system";
    }).outPath
    + "/bin/auto-audit"
  );
in
{
  launchd.agents.auto-audit = {
    enable = true;
    config = {
      ProgramArguments = [ program ];
      ProcessType = "Background";
      StartCalendarInterval = [
        {
          Hour = 0;
          Minute = 0;
        }
      ];
      StandardErrorPath = "/tmp/auto-audit.err";
      StandardOutPath = "/tmp/auto-audit.out";
    };
  };
  systemd.user = {
    timers.auto-audit = {
      Unit.Description = "Lynis audit timer";
      Install.WantedBy = [ "timers.target" ];
      Timer = {
        OnCalendar = "daily";
        Unit = "auto-audit.service";
        Persistent = true;
      };
    };
    services.auto-audit = {
      Unit.Description = "Lynis audit service";
      Service.ExecStart = program;
    };
  };
}
