{ config, pkgs, lib, ... }:
let
  settings-directory =
    if pkgs.stdenv.hostPlatform.isDarwin
    then "$HOME/Library/Application Support/Code/User"
    else "$HOME/.config/Code/User";

  defaultExtensions = { "remote.SSH.defaultExtensions" = map (x: x.vscodeExtUniqueId) extensions; };

  userSettings = (builtins.fromJSON (builtins.readFile ./settings.json)) // defaultExtensions;

  keybindings = builtins.fromJSON (builtins.readFile ./keybindings.json);

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
    ms-python.black-formatter
    ms-python.isort
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
      name = "flake8";
      publisher = "ms-python";
      version = "2023.6.0";
      sha256 = "Hk7rioPvrxV0zMbwdighBAlGZ43rN4DLztTyiHqO6o4=";
    }
    {
      name = "git-line-blame";
      publisher = "carlthome";
      version = "0.4.0";
      sha256 = "rEhx50/OMi3glrhhC3hPhqXHEzPaTskGFvZ06CjzFkQ=";
    }
    {
      name = "copilot-chat";
      publisher = "github";
      version = "0.8.0";
      sha256 = "IJ75gqsQj0Ukjlrqevum5AoaeZ5vOfxX/4TceXe+EIg=";
    }
  ] ++ lib.optionals (pkgs.config.allowUnfreePredicate "vscode") [
    github.copilot
    ms-python.vscode-pylance
    ms-vscode-remote.remote-ssh
    ms-vscode-remote.remote-containers
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
