{ config, pkgs, home, ... }: {
  home.stateVersion = "22.05";
  home.enableNixpkgsReleaseCheck = true;
  fonts.fontconfig.enable = true;

  home.packages = with pkgs;
    let
      python = python3.withPackages (ps:
        with ps; [
          black
          jax
          jaxlib
          librosa
          matplotlib
          mypy
          pytorch
          tensorflow
          flake8
          ipython
          isort
          numpy
          opencv
          pandas
          pip
          scipy
          setuptools
        ]);
    in
    [
      act
      awscli
      black
      cachix
      caprine-bin
      cargo
      coreutils
      curl
      docker
      docker-compose
      ffmpeg-full
      git
      google-cloud-sdk
      jq
      jupyter
      libsndfile
      nerdfonts
      nixpkgs-fmt
      nodejs
      nodePackages.npm
      nodePackages.prettier
      opencv
      pdfgrep
      poetry
      pre-commit
      python3Packages.ipython
      python3Packages.numpy
      #reaper
      rclone
      rsync
      rustc
      shellcheck
      slack
      sox
      #tdesktop
      tree
      victor-mono
      wget
    ];

  programs.vim.enable = true;

  programs.fish.enable = true;
  programs.zsh.enable = true;
  programs.nushell.enable = true;
  programs.bash.enable = true;
  programs.tmux.enable = true;

  # Enable Docker BuildKit globally by default.
  home.sessionVariables = {
    DOCKER_BUILDKIT = true;
  };

  # TODO Add VST bridge to PATH.
  # export PATH="$PATH:$HOME/.local/share/yabridge"

  home.shellAliases = {
    d = "docker run --rm -it";
    k = "kubectl";
    g = "gcloud beta interactive";
  };

  programs.command-not-found.enable = true;

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
    enableFishIntegration = true;
  };

  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

  programs.git = {
    enable = true;
    userName = "Carl Thomé";
    userEmail = "carlthome@gmail.com";
  };
  #programs.git.delta.enable = true;
  programs.git.diff-so-fancy.enable = true;
  #programs.git.difftastic.enable = true;
  programs.gitui.enable = true;
  programs.gh.enable = true;

  # TODO GUI programs too?
  #programs.gnome-terminal.enable = true;
  #programs.firefox.enable = true;
  #programs.chromium.enable = true;

  programs.vscode = {
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
  };
}
