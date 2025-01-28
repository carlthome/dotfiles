{ nixpkgs-unstable, ... }:

final: prev:
let
  pkgs = import nixpkgs-unstable {
    system = prev.system;
    config.allowUnfreePredicate =
      pkg:
      builtins.elem (nixpkgs-unstable.lib.getName pkg) [
        "vscode"
        "vscode-extension-github-copilot"
        "vscode-extension-github-copilot-chat"
        "vscode-extension-MS-python-vscode-pylance"
        "vscode-extension-ms-vscode-cpptools"
        "vscode-extension-ms-vscode-remote-remote-ssh"
        "vscode-extension-ms-vsliveshare-vsliveshare"
        "vscode-extension-ms-vscode-remote-remote-containers"
      ];
  };
in
{
  vscode = pkgs.vscode;
  vscode-extensions = pkgs.vscode-extensions;
}
