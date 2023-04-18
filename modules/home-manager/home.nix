{ config, pkgs, lib, ... }: {
  imports = [
    ./vscode.nix
  ];

  fonts.fontconfig.enable = true;

  home.stateVersion = "22.11";
  home.enableNixpkgsReleaseCheck = true;
  home.sessionVariables = {
    DOCKER_BUILDKIT = true;
    EDITOR = "code";
  };

  home.shellAliases = {
    d = "docker run --rm -it";
    k = "kubectl";
    g = "gcloud beta interactive";
  };

  home.packages = with pkgs; [
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
    # TODO Broken on macOS.
    #dvc-with-remotes
    fantasque-sans-mono
    ffmpeg-full
    gcc
    gnumake
    gnupg
    (google-cloud-sdk.withExtraComponents (with google-cloud-sdk.components; [
      gke-gcloud-auth-plugin
      # TODO Broken on macOS.
      # cloud-build-local
    ]))
    jq
    jujutsu
    kind
    kubectl
    kubectx
    kubernetes-helm
    minikube
    ncdu
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
  };
}
