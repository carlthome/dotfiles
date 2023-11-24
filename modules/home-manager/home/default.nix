{ config, pkgs, lib, self, nixpkgs, nixpkgs-unstable, ... }: {

  nix = {
    registry.nixpkgs.flake = nixpkgs;
    registry.nixpkgs-unstable.flake = nixpkgs-unstable;
    registry.dotfiles.flake = self;
  };

  home.sessionVariables = {
    DOCKER_BUILDKIT = "1";
    EDITOR = "code";
  };

  home.shellAliases = {
    d = "docker run --rm -it";
    k = "kubectl";
    g = "git";
    ll = "ls -al";
    clean = "git clean --interactive";
    commit = "git commit --patch";
    rebase = "git rebase --interactive";
    restore = "git restore --patch --source";
    push = "git push";
    pull = "git pull";
    build = "nix build";
    run = "nix run";
    develop = "nix develop";
    edit = "nix edit";
    update = "nix flake update --commit-lock-file";
    switch-home = "home-manager switch --flake .";
    list-open-ports = "sudo netstat --tcp --udp --listening --program --numeric | grep LISTEN";
  };

  programs = {
    home-manager.enable = true;
    man.enable = true;
    fish.enable = true;
    fzf = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      enableFishIntegration = true;
    };
    zsh.enable = true;
    nushell.enable = true;
    bash.enable = true;
    tmux.enable = true;
    nnn.enable = true;
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
    gpg.enable = true;
    gitui.enable = true;
    gh = {
      enable = true;
      settings.git_protocol = "ssh";
      enableGitCredentialHelper = false;
    };
  };

  home.packages = with pkgs; [
    act
    actionlint
    asdf-vm
    autoflake
    awscli
    black
    buildah
    buildkit
    cachix
    cmake
    comma
    cookiecutter
    copier
    coreutils-full
    ctags
    curl
    dive
    docker-client
    docker-slim
    duckdb
    fantasque-sans-mono
    fdupes
    ffmpeg-full
    gcc
    gnumake
    gnupg
    (google-cloud-sdk.withExtraComponents (with google-cloud-sdk.components; [
      gke-gcloud-auth-plugin
    ]))
    hadolint
    htop
    isort
    jq
    jujutsu
    # TODO Jupyter is currently broken.
    #jupyter
    k9s
    keepassxc
    kind
    kubectl
    kubectx
    kubernetes-helm
    lame
    mdcat
    minikube
    mypy
    ncdu
    nil
    ninja
    nix-init
    nix-tree
    nix-diff
    nix-info
    nixfmt
    nixpkgs-fmt
    nixpkgs-review
    nodejs
    nodePackages.npm
    nodePackages.prettier
    pass
    pdfgrep
    pdm
    pipenv
    pipx
    podman
    poetry
    postgresql
    pre-commit
    python3
    python3Packages.pip
    python3Packages.tensorboard
    pyupgrade
    rclone
    restic
    ripgrep
    rsync
    rustup
    shellcheck
    skaffold
    sops
    sox
    spr
    sqlitebrowser
    syft
    terraform
    tree
    visidata
    wget
    yarn
  ];

  fonts.fontconfig.enable = true;
  home.enableNixpkgsReleaseCheck = true;
  home.stateVersion = "22.11";
}
