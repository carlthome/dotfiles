{ config, pkgs, lib, self, ... }:
let
  settings-directory =
    if pkgs.stdenv.hostPlatform.isDarwin
    then "$HOME/Library/Application Support/Code/User"
    else "$HOME/.config/Code/User";

  userSettings = builtins.fromJSON (builtins.readFile "${self}/modules/home-manager/vscode/settings.json");

  keybindings = builtins.fromJSON (builtins.readFile "${self}/modules/home-manager/vscode/keybindings.json");

  extensions = with pkgs.vscode-extensions; [
    davidanson.vscode-markdownlint
    dbaeumer.vscode-eslint
    esbenp.prettier-vscode
    github.github-vscode-theme
    github.vscode-github-actions
    github.vscode-pull-request-github
    gitlab.gitlab-workflow
    hashicorp.terraform
    jnoortheen.nix-ide
    mikestead.dotenv
    ms-azuretools.vscode-docker
    ms-kubernetes-tools.vscode-kubernetes-tools
    ms-python.python
    ms-toolsai.jupyter
    ms-toolsai.vscode-jupyter-slideshow
    ms-vscode.cmake-tools
    ms-vscode.makefile-tools
    njpwerner.autodocstring
    pkief.material-icon-theme
    redhat.vscode-yaml
    rust-lang.rust-analyzer
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
    {
      name = "black-formatter";
      publisher = "ms-python";
      version = "2023.4.1";
      sha256 = "IJaLke0WF1rlKTiuwJHAXDQB1SS39AoQhc4iyqqlTyY=";
    }
    {
      name = "flake8";
      publisher = "ms-python";
      version = "2023.6.0";
      sha256 = "Hk7rioPvrxV0zMbwdighBAlGZ43rN4DLztTyiHqO6o4=";
    }
    {
      name = "isort";
      publisher = "ms-python";
      version = "2023.10.1";
      sha256 = "NRsS+mp0pIhGZiqxAMXNZ7SwLno9Q8pj+RS1WB92HzU=";
    }
    {
      name = "git-line-blame";
      publisher = "carlthome";
      version = "0.4.0";
      sha256 = "rEhx50/OMi3glrhhC3hPhqXHEzPaTskGFvZ06CjzFkQ=";
    }
  ] ++ lib.optionals (pkgs.config.allowUnfreePredicate "vscode") [
    github.copilot
    ms-python.vscode-pylance
    ms-vscode-remote.remote-ssh
    #TODO Broken on darwin.
    #ms-vscode.cpptools
    #ms-vsliveshare.vsliveshare
  ];
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
