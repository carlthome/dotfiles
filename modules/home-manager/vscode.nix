{ config, pkgs, lib, self, ... }:
let
  settings-path =
    if pkgs.stdenv.hostPlatform.isDarwin
    then "$HOME/Library/Application Support/Code/User/settings.json"
    else "$HOME/.config/Code/User/settings.json";

  userSettings = builtins.fromJSON (builtins.readFile "${self}/modules/home-manager/settings.json");

  extensions = with pkgs.vscode-extensions; [
    davidanson.vscode-markdownlint
    eamodio.gitlens
    esbenp.prettier-vscode
    github.github-vscode-theme
    github.vscode-pull-request-github
    gitlab.gitlab-workflow
    hashicorp.terraform
    jnoortheen.nix-ide
    mikestead.dotenv
    ms-azuretools.vscode-docker
    ms-kubernetes-tools.vscode-kubernetes-tools
    ms-python.python
    ms-toolsai.jupyter
    ms-vscode.cmake-tools
    ms-vscode.makefile-tools
    njpwerner.autodocstring
    pkief.material-icon-theme
    redhat.vscode-yaml
    stkb.rewrap
    svelte.svelte-vscode
    tamasfe.even-better-toml
    twxs.cmake
  ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
    {
      name = "noctis";
      publisher = "liviuschera";
      version = "10.40.0";
      sha256 = "UbGWorOVeitE9Q6tZ18h9K4Noz5Y3oaiuYaJtPzcwOc=";
    }
  ] ++ lib.optionals (pkgs.config.allowUnfreePredicate "vscode") [
    github.copilot
    ms-python.vscode-pylance
    ms-vscode.cpptools
    ms-vsliveshare.vsliveshare
  ];
in
{
  programs.vscode = {
    inherit userSettings extensions;
    enable = true;
    package = if pkgs.config.allowUnfreePredicate "vscode" then pkgs.vscode else pkgs.vscodium;
  };

  # Copy VS Code settings into the default location as a mutable copy.
  home.activation = {
    beforeCheckLinkTargets = {
      after = [ ];
      before = [ "checkLinkTargets" ];
      data = ''
        rm "${settings-path}"
      '';
    };

    afterWriteBoundary = {
      after = [ "writeBoundary" ];
      before = [ ];
      data = ''
        cat ${(pkgs.formats.json {}).generate "settings.json" userSettings} > "${settings-path}"
      '';
    };
  };
}
