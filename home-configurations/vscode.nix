{ pkgs, ... }: {
  enable = true;
  package = pkgs.vscode;
  extensions = with pkgs.vscode-extensions; [
    bbenoist.nix
    davidanson.vscode-markdownlint
    github.copilot
    github.github-vscode-theme
    github.vscode-pull-request-github
    gitlab.gitlab-workflow
    hashicorp.terraform
    jnoortheen.nix-ide
    ms-azuretools.vscode-docker
    ms-kubernetes-tools.vscode-kubernetes-tools
    ms-python.vscode-pylance
    ms-toolsai.jupyter
    ms-vscode-remote.remote-ssh
    njpwerner.autodocstring
    pkief.material-icon-theme
    redhat.java
    redhat.vscode-yaml
    svelte.svelte-vscode
  ];
  userSettings = {
    "[python]" = { "editor.defaultFormatter" = "ms-python.python"; };
    "[yaml]" = { "editor.defaultFormatter" = "googlecloudtools.cloudcode"; };
    "cloudcode.enableTelemetry" = false;
    "cmake.configureOnOpen" = true;
    "debug.allowBreakpointsEverywhere" = true;
    "editor.fontFamily" = "Ubuntu Mono, Menlo, Victor Mono, monospace";
    "editor.fontLigatures" = true;
    "editor.formatOnSave" = true;
    "editor.inlineSuggest.enabled" = true;
    "editor.suggestSelection" = "first";
    "explorer.excludeGitIgnore" = true;
    "git.autofetch" = true;
    "jupyter.askForKernelRestart" = false;
    "jupyter.runStartupCommands" = [ "%load_ext autoreload" "%autoreload 2" ];
    "redhat.telemetry.enabled" = false;
    "telemetry.telemetryLevel" = "off";
    "terminal.integrated.defaultProfile.linux" = "fish";
    "terminal.integrated.defaultProfile.osx" = "fish";
    "terminal.integrated.defaultProfile.windows" = "fish";
    "terminal.integrated.enableMultiLinePasteWarning" = false;
    "window.restoreWindows" = "none";
    "window.titleBarStyle" = "custom";
    "workbench.colorTheme" = "Material";
    "workbench.enableExperiments" = false;
    "workbench.iconTheme" = "material-icon-theme";
    "workbench.layoutControl.enabled" = true;
    "workbench.settings.enableNaturalLanguageSearch" = false;
  };
}
