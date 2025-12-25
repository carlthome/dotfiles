{ pkgs, lib, ... }:
let
  script = pkgs.writeShellApplication {
    name = "auto-audit";
    text = builtins.readFile ./script.sh;
    runtimeInputs = with pkgs; [ lynis ];
  };
in
{
  launchd.agents.auto-audit = {
    enable = true;
    config = {
      Program = lib.getExe script;
      ProcessType = "Background";
      StartCalendarInterval = [
        {
          Hour = 0;
          Minute = 0;
        }
      ];
      StandardErrorPath = "/tmp/${script.name}.err";
      StandardOutPath = "/tmp/${script.name}.out";
    };
  };
  systemd.user = {
    timers.auto-audit = {
      Install.WantedBy = [ "timers.target" ];
      Timer = {
        OnCalendar = "daily";
        Unit = "${script.name}.service";
        Persistent = true;
      };
    };
    services.auto-audit = {
      Service.ExecStart = lib.getExe script;
    };
  };
}
