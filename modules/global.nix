{ config, pkgs, ... }: {
  fonts.fontconfig.enable = true;
  home = {
    stateVersion = "22.11";
    enableNixpkgsReleaseCheck = true;
    sessionVariables = {
      DOCKER_BUILDKIT = true;
    };
    shellAliases = {
      d = "docker run --rm -it";
      k = "kubectl";
      g = "gcloud beta interactive";
    };
    packages = with pkgs; [
      act
      awscli
      cachix
      cmake
      cookiecutter
      coreutils-full
      curl
      dive
      docker-client
      # TODO Broken.
      #dvc-with-remotes
      fantasque-sans-mono
      ffmpeg-full
      gitFull
      gnumake
      gnupg
      google-cloud-sdk
      jq
      kind
      kubectl
      kubectx
      kubernetes-helm
      minikube
      ninja
      nixfmt
      nixpkgs-fmt
      nodejs
      nodePackages.npm
      nodePackages.prettier
      pdfgrep
      pipenv
      poetry
      pre-commit
      (python3.withPackages (ps: with ps; [
        #wandb
        black
        docformatter
        flake8
        isort
        mypy
        pip
        pytest
        tensorboard
      ]))
      rclone
      ripgrep
      rsync
      rustup
      shellcheck
      skaffold
      sox
      spr
      sqlitebrowser
      tree
      wget
      yarn
    ];
  };
  programs = {
    home-manager.enable = true;
    man.enable = true;
    vim.enable = true;
    fish.enable = true;
    zsh.enable = true;
    nushell.enable = true;
    bash.enable = true;
    tmux.enable = true;
    starship = {
      enable = true;
      enableZshIntegration = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
    };
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
    git = {
      enable = true;
      package = pkgs.gitFull;
      userName = "Carl Thomé";
      lfs.enable = true;
      extraConfig = {
        init.defaultBranch = "main";
        pull.ff = "only";
        push.autoSetupRemote = true;
        user.useConfigOnly = true;
      };
    };
    gitui.enable = true;
    gh = {
      enable = true;
      settings.git_protocol = "ssh";
      enableGitCredentialHelper = false;
    };
    vscode = {
      enable = true;
      package = pkgs.vscode; #TODO pkgs.vscodium if unfree disabled.
      extensions = with pkgs.vscode-extensions; [
        arrterian.nix-env-selector
        bbenoist.nix
        davidanson.vscode-markdownlint
        esbenp.prettier-vscode
        github.github-vscode-theme
        github.vscode-pull-request-github
        gitlab.gitlab-workflow
        hashicorp.terraform
        jnoortheen.nix-ide
        mkhl.direnv
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
      ] ++ (lib.optionals (pkgs.stdenv.isLinux) [
        github.copilot
        ms-python.vscode-pylance
        ms-vsliveshare.vsliveshare
      ]);
      userSettings = {
        "[dockercompose]" = { "editor.defaultFormatter" = "ms-azuretools.vscode-docker"; };
        "[python]" = { "editor.defaultFormatter" = "ms-python.python"; };
        "[yaml]" = { "editor.defaultFormatter" = "redhat.vscode-yaml"; };
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
        "redhat.telemetry.enabled" = false;
        "telemetry.telemetryLevel" = "off";
        "terminal.integrated.defaultProfile.linux" = "fish";
        "terminal.integrated.defaultProfile.osx" = "fish";
        "terminal.integrated.defaultProfile.windows" = "fish";
        "terminal.integrated.enableMultiLinePasteWarning" = false;
        "update.mode" = "none";
        "window.autoDetectColorScheme" = true;
        "window.commandCenter" = true;
        "window.restoreWindows" = "none";
        "window.titleBarStyle" = "custom";
        "window.zoomLevel" = 1;
        "workbench.enableExperiments" = false;
        "workbench.iconTheme" = "material-icon-theme";
        "workbench.layoutControl.enabled" = true;
        "workbench.preferredDarkColorTheme" = "Noctis Obscuro";
        "workbench.preferredLightColorTheme" = "Jupyter Theme";
        "workbench.settings.enableNaturalLanguageSearch" = false;
      };
    };
  };
}
