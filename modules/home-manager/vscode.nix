{ config, pkgs, lib, ... }:
let
  settings-path =
    if pkgs.stdenv.hostPlatform.isDarwin
    then "$HOME/Library/Application Support/Code/User/settings.json"
    else "$HOME/.config/Code/User/settings.json";

  userSettings = {
    "[css]" = { "editor.defaultFormatter" = "esbenp.prettier-vscode"; };
    "[dockercompose]" = { "editor.defaultFormatter" = "ms-azuretools.vscode-docker"; };
    "[dockerfile]" = { "editor.defaultFormatter" = "ms-azuretools.vscode-docker"; };
    "[javascript]" = { "editor.defaultFormatter" = "esbenp.prettier-vscode"; };
    "[jsonc]" = { "editor.defaultFormatter" = "vscode.json-language-features"; };
    "[nix]" = { "editor.defaultFormatter" = "jnoortheen.nix-ide"; };
    "[python]" = { "editor.defaultFormatter" = "ms-python.python"; };
    "[toml]" = { "editor.defaultFormatter" = "tamasfe.even-better-toml"; };
    "[yaml]" = { "editor.defaultFormatter" = "redhat.vscode-yaml"; };
    "cloudcode.autoDependencies" = "off";
    "cloudcode.enableTelemetry" = false;
    "cmake.configureOnOpen" = true;
    "debug.allowBreakpointsEverywhere" = true;
    "debug.openExplorerOnEnd" = true;
    "editor.defaultFormatter" = "esbenp.prettier-vscode";
    "editor.fontFamily" = "Fantasque Sans Mono, monospace";
    "editor.fontLigatures" = true;
    "editor.fontSize" = 14;
    "editor.formatOnSave" = true;
    "editor.inlineSuggest.enabled" = true;
    "editor.mouseWheelZoom" = true;
    "editor.suggestSelection" = "first";
    "files.insertFinalNewline" = true;
    "files.trimFinalNewlines" = true;
    "files.trimTrailingWhitespace" = true;
    "git.allowNoVerifyCommit" = true;
    "git.autofetch" = true;
    "git.confirmSync" = false;
    "git.suggestSmartCommit" = false;
    "git.terminalGitEditor" = true;
    "git.untrackedChanges" = "separate";
    "github.copilot-labs.showBrushesLenses" = false;
    "github.copilot-labs.showTestGenerationLenses" = true;
    "github.copilot.enable" = { "*" = true; "yaml" = true; "plaintext" = true; "markdown" = true; };
    "github.gitProtocol" = "ssh";
    "githubPullRequests.pullBranch" = "always";
    "githubPullRequests.pushBranch" = "always";
    "githubPullRequests.setAutoMerge" = true;
    "jupyter.askForKernelRestart" = false;
    "jupyter.runStartupCommands" = [ "%load_ext autoreload" "%autoreload 2" ];
    "nix.enableLanguageServer" = true;
    "nix.serverPath" = "nil";
    "nix.serverSettings" = { "nil" = { "formatting" = { "command" = [ "nixpkgs-fmt" ]; }; }; };
    "notebook.formatOnSave.enabled" = true;
    "python.analysis.typeCheckingMode" = "basic";
    "python.formatting.provider" = "black";
    "redhat.telemetry.enabled" = false;
    "telemetry.telemetryLevel" = "off";
    "terminal.integrated.defaultProfile.linux" = "fish";
    "terminal.integrated.defaultProfile.osx" = "fish";
    "terminal.integrated.defaultProfile.windows" = "fish";
    "terminal.integrated.enableMultiLinePasteWarning" = false;
    "terminal.integrated.fontSize" = 14;
    "update.mode" = "none";
    "window.autoDetectColorScheme" = true;
    "window.commandCenter" = true;
    "window.restoreWindows" = "none";
    "window.titleBarStyle" = "custom";
    "window.zoomLevel" = 0;
    "workbench.colorTheme" = "Noctis";
    "workbench.editor.limit.enabled" = true;
    "workbench.editor.limit.excludeDirty" = true;
    "workbench.editor.limit.value" = 5;
    "workbench.enableExperiments" = false;
    "workbench.iconTheme" = "material-icon-theme";
    "workbench.layoutControl.enabled" = true;
    "workbench.preferredDarkColorTheme" = "GitHub Dark";
    "workbench.preferredLightColorTheme" = "GitHub Light";
    "workbench.settings.enableNaturalLanguageSearch" = false;
    "workbench.startupEditor" = "readme";
  };

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
