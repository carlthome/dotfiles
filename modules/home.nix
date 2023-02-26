{ config, pkgs, lib, ... }: {
  fonts.fontconfig.enable = true;
  nix = {
    package = pkgs.nix;
    settings = {
      experimental-features = "nix-command flakes";
      auto-optimise-store = true;
      allow-dirty = true;
      extra-substituters = [
        "https://cuda-maintainers.cachix.org"
        "https://nixpkgs-unfree.cachix.org"
        "https://numtide.cachix.org"
      ];
      extra-trusted-public-keys = [
        "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
        "nixpkgs-unfree.cachix.org-1:hqvoInulhbV4nJ9yJOEr+4wxhDV4xq2d1DK7S6Nj6rs="
        "numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE="
      ];
    };
  };
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
      asdf-vm
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
      gcc
      gnumake
      gnupg
      google-cloud-sdk
      jq
      jujutsu
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
      postgresql
      pre-commit
      python3Packages.tensorboard
      rclone
      ripgrep
      rsync
      rustup
      shellcheck
      skaffold
      sox
      spr
      sqlitebrowser
      terraform
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
      package = if pkgs.config.allowUnfree then pkgs.vscode else pkgs.vscodium;
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
      ] ++ (lib.optionals pkgs.config.allowUnfree [
        github.copilot
        ms-python.vscode-pylance
        ms-vscode.cpptools
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
        "window.zoomLevel" = 0;
        "workbench.colorTheme" = "GitHub Light";
        "workbench.enableExperiments" = false;
        "workbench.iconTheme" = "material-icon-theme";
        "workbench.layoutControl.enabled" = true;
        "workbench.preferredDarkColorTheme" = "GitHub Dark";
        "workbench.preferredLightColorTheme" = "GitHub Light";
        "workbench.settings.enableNaturalLanguageSearch" = false;
      };
    };
  };
}
