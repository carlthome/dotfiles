{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.terminal-profile;

  profileList = lib.concatStringsSep ", " (map (p: ''"${p}"'') cfg.profiles);

  script = pkgs.writeShellApplication {
    name = "change-terminal-profile";
    text = ''
      [ "''${TERM_PROGRAM:-}" = "Apple_Terminal" ] || exit 0
      osascript -e '
      tell application "Terminal"
        set profiles to {${profileList}}
        set idx to random number from 1 to (count of profiles)
        set current settings of selected tab of front window to settings set (item idx of profiles)
      end tell'
    '';
  };
in
{
  options.services.terminal-profile = {
    enable = lib.mkEnableOption "Auto-change Terminal.app profile on each new tab";

    profiles = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "Basic"
        "Grass"
        "Homebrew"
        "Man Page"
        "Novel"
        "Ocean"
        "Pro"
        "Red Sands"
        "Silver Aerogel"
      ];
      description = "Terminal.app profile names to randomly rotate through on each new tab.";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.zsh.interactiveShellInit = "${lib.getExe script} 2>/dev/null || true";
    programs.bash.interactiveShellInit = "${lib.getExe script} 2>/dev/null || true";
  };
}
