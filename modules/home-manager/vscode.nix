{ config, pkgs, lib, ... }: rec {
  programs.vscode = {
    enable = true;
    package = if pkgs.config.allowUnfreePredicate "vscode" then pkgs.vscode else pkgs.vscodium;
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
      twxs.cmake
    ] ++ (lib.optionals (pkgs.config.allowUnfreePredicate "vscode") [
      github.copilot
      ms-python.vscode-pylance
      ms-vscode.cpptools
      ms-vsliveshare.vsliveshare
    ]);
    userSettings = {
      "[css]" = { "editor.defaultFormatter" = "esbenp.prettier-vscode"; };
      "[dockercompose]" = { "editor.defaultFormatter" = "ms-azuretools.vscode-docker"; };
      "[javascript]" = { "editor.defaultFormatter" = "esbenp.prettier-vscode"; };
      "[jsonc]" = { "editor.defaultFormatter" = "vscode.json-language-features"; };
      "[nix]" = { "editor.defaultFormatter" = "jnoortheen.nix-ide"; };
      "[python]" = { "editor.defaultFormatter" = "ms-python.python"; };
      "[yaml]" = { "editor.defaultFormatter" = "redhat.vscode-yaml"; };
      "cloudcode.autoDependencies" = "off";
      "cloudcode.enableTelemetry" = false;
      "cmake.configureOnOpen" = true;
      "debug.allowBreakpointsEverywhere" = true;
      "editor.defaultFormatter" = "esbenp.prettier-vscode";
      "editor.fontFamily" = "Fantasque Sans Mono, monospace";
      "editor.fontLigatures" = true;
      "editor.fontSize" = 14;
      "editor.formatOnSave" = true;
      "editor.inlineSuggest.enabled" = true;
      "editor.mouseWheelZoom" = true;
      "editor.suggestSelection" = "first";
      "git.autofetch" = true;
      "git.confirmSync" = false;
      "git.suggestSmartCommit" = false;
      "jupyter.askForKernelRestart" = false;
      "jupyter.runStartupCommands" = [ "%load_ext autoreload" "%autoreload 2" ];
      "notebook.formatOnSave.enabled" = true;
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
      "workbench.colorTheme" = "GitHub Light";
      "workbench.enableExperiments" = false;
      "workbench.iconTheme" = "material-icon-theme";
      "workbench.layoutControl.enabled" = true;
      "workbench.preferredDarkColorTheme" = "GitHub Dark";
      "workbench.preferredLightColorTheme" = "GitHub Light";
      "workbench.settings.enableNaturalLanguageSearch" = false;
      "github.copilot-labs.showBrushesLenses" = true;
      "github.copilot-labs.showTestGenerationLenses" = true;
      "github.copilot.enable" = {
        "*" = true;
        "yaml" = true;
        "plaintext" = true;
        "markdown" = true;
      };
      "githubPullRequests.pullBranch" = "never";
    };
  };

  # Copy VS Code settings into the default location as a mutable copy.
  home.activation =
    let
      vscode-default-settings =
        if pkgs.stdenv.hostPlatform.isDarwin
        then "$HOME/Library/Application Support/Code/User/settings.json"
        else "$HOME/.config/Code/User/settings.json";
    in
    {
      beforeCheckLinkTargets = {
        after = [ ];
        before = [ "checkLinkTargets" ];
        data = ''
          rm "${vscode-default-settings}"
        '';
      };

      afterWriteBoundary = {
        after = [ "writeBoundary" ];
        before = [ ];
        data = ''
          cat ${(pkgs.formats.json {}).generate "settings.json" programs.vscode.userSettings} > "${vscode-default-settings}"
        '';
      };
    };
}
