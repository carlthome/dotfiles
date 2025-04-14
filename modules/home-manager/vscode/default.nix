{
  config,
  pkgs,
  lib,
  nix-vscode-extensions,
  ...
}:
let
  settings-directory =
    if pkgs.stdenv.hostPlatform.isDarwin then
      "$HOME/Library/Application Support/Code/User"
    else
      "$HOME/.config/Code/User";
  defaultExtensions = {
    "remote.SSH.defaultExtensions" = map (x: x.vscodeExtUniqueId) extensions;
  };
  userSettings = (builtins.fromJSON (builtins.readFile ./settings.json)) // defaultExtensions;
  keybindings = builtins.fromJSON (builtins.readFile ./keybindings.json);
  userTasks = builtins.fromJSON (builtins.readFile ./tasks.json);

  extensions = import ./extensions.nix {
    inherit pkgs;
    vscode-extensions = nix-vscode-extensions.extensions.${pkgs.system};
  };
in
{
  programs.vscode = {
    inherit
      userSettings
      userTasks
      extensions
      keybindings
      ;
    enable = true;
    enableUpdateCheck = false;
    enableExtensionUpdateCheck = false;
    mutableExtensionsDir = false;
    package = if pkgs.config.allowUnfreePredicate "vscode" then pkgs.vscode else pkgs.vscodium;
  };
}
