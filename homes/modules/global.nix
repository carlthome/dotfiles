{ pkgs, ... }: {
  fonts.fontconfig.enable = true;
  home = {
    stateVersion = "22.05";
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
      docker
      docker-compose
      fantasque-sans-mono
      ffmpeg-full
      git
      gnumake
      gnupg
      google-cloud-sdk
      jq
      kind
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
      yarn
      (python3.withPackages (ps: with ps; [
        #jax
        #jaxlib
        #pytorch
        #tensorflow
        librosa
        matplotlib
        mypy
        black
        scikit-learn
        flake8
        ipython
        isort
        numpy
        pandas
        jupyter
        scipy
      ])
      )
      ripgrep
      rclone
      rsync
      rustup
      shellcheck
      sox
      sqlitebrowser
      tree
      wget
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
      userName = "Carl Thomé";
      # TODO Play around with non-standard git diff extensions.
      delta.enable = false;
      diff-so-fancy.enable = false;
      difftastic.enable = false;
      extraConfig = {
        init.defaultBranch = "main";
        push.autoSetupRemote = true;
      };
    };
    gitui.enable = true;
    gh = {
      enable = true;
      settings.git_protocol = "ssh";
      enableGitCredentialHelper = false;
    };
    vscode = {
      enable = false; # TODO
      package = pkgs.vscodium;
      extensions = with pkgs.vscode-extensions; [
        bbenoist.nix
        davidanson.vscode-markdownlint
        #github.copilot
        github.github-vscode-theme
        github.vscode-pull-request-github
        gitlab.gitlab-workflow
        hashicorp.terraform
        jnoortheen.nix-ide
        ms-azuretools.vscode-docker
        ms-kubernetes-tools.vscode-kubernetes-tools
        #ms-python.vscode-pylance
        ms-toolsai.jupyter
        #ms-vscode-remote.remote-ssh
        njpwerner.autodocstring
        pkief.material-icon-theme
        redhat.java
        redhat.vscode-yaml
        svelte.svelte-vscode
      ];
      userSettings = {
        "[python]" = { "editor.defaultFormatter" = "ms-python.black-formatter"; };
        "[yaml]" = { "editor.defaultFormatter" = "redhat.vscode-yaml"; };
        "cloudcode.enableTelemetry" = false;
        "cmake.configureOnOpen" = true;
        "debug.allowBreakpointsEverywhere" = true;
        "editor.fontFamily" = "Fantasque Sans Mono";
        "editor.fontLigatures" = true;
        "editor.fontSize" = 14;
        "editor.formatOnSave" = true;
        "editor.inlineSuggest.enabled" = true;
        "editor.mouseWheelZoom" = true;
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
