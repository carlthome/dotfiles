{ config, pkgs, lib, ... }:
let
  settings-directory =
    if pkgs.stdenv.hostPlatform.isDarwin
    then "$HOME/Library/Application Support/Code/User"
    else "$HOME/.config/Code/User";
  defaultExtensions = { "remote.SSH.defaultExtensions" = map (x: x.vscodeExtUniqueId) extensions; };
  userSettings = (builtins.fromJSON (builtins.readFile ./settings.json)) // defaultExtensions;
  keybindings = builtins.fromJSON (builtins.readFile ./keybindings.json);
  extensions = import ./extensions.nix { inherit pkgs; };
in
{
  programs.vscode = {
    inherit userSettings extensions keybindings;
    enable = true;
    mutableExtensionsDir = false;
    package = if pkgs.config.allowUnfreePredicate "vscode" then pkgs.vscode else pkgs.vscodium;
  };

  # Copy VS Code settings into the default location as a mutable copy.
  home.activation = {
    beforeCheckLinkTargets = {
      after = [ ];
      before = [ "checkLinkTargets" ];
      data = ''
        if [ -f "${settings-directory}/settings.json" ]; then
          rm "${settings-directory}/settings.json"
        fi
        if [ -f "${settings-directory}/keybindings.json" ]; then
          rm "${settings-directory}/keybindings.json"
        fi
      '';
    };

    afterWriteBoundary = {
      after = [ "writeBoundary" ];
      before = [ ];
      data = ''
        cat ${(pkgs.formats.json {}).generate "settings.json" userSettings} > "${settings-directory}/settings.json"
        cat ${(pkgs.formats.json {}).generate "keybindings.json" keybindings} > "${settings-directory}/keybindings.json"
      '';
    };
  };
}
