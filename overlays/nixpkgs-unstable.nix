{ nixpkgs-unstable, ... }:

final: prev:
let
  pkgs = import nixpkgs-unstable {
    system = prev.stdenv.hostPlatform.system;
    config.allowUnfreePredicate =
      pkg:
      builtins.elem (nixpkgs-unstable.lib.getName pkg) [
        "vscode"
        "claude-code"
        "vscode-extension-github-copilot"
        "vscode-extension-github-copilot-chat"
        "vscode-extension-MS-python-vscode-pylance"
        "vscode-extension-ms-vscode-cpptools"
        "vscode-extension-ms-vscode-remote-remote-ssh"
        "vscode-extension-ms-vsliveshare-vsliveshare"
        "vscode-extension-ms-vscode-remote-remote-containers"
        "vscode-extension-ms-toolsai-datawrangler"
        "vscode-extension-anthropic-claude-code"
      ];
  };
in
{
  vscode = pkgs.vscode;
  vscode-extensions = pkgs.vscode-extensions;
  skypilot = pkgs.skypilot;
}
