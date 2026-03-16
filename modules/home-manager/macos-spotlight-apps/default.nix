{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.services.macos-spotlight-apps;

  script = pkgs.writeShellApplication {
    name = "mk-macos-spotlight-apps";
    runtimeInputs = with pkgs; [
      coreutils
      findutils
    ];
    text = builtins.readFile ./script.sh;
  };
in
{
  options.services.macos-spotlight-apps = {
    enable = lib.mkEnableOption "Create wrapper apps for Spotlight indexing";

    target = lib.mkOption {
      type = lib.types.str;
      default = "${config.home.homeDirectory}/Applications/Nix";
      description = "Directory to create wrapper apps in";
    };
  };

  config = lib.mkIf cfg.enable {
    home.activation.macos-spotlight-apps = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
      $DRY_RUN_CMD ${lib.getExe script} \
        "$newGenPath/home-path/Applications" \
        "${cfg.target}"
    '';
  };
}
