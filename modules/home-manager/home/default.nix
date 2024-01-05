{ config, pkgs, lib, ... }@inputs: {

  # Add each flake input to registry.
  nix.registry = (lib.mapAttrs (_: flake: { inherit flake; })) ((lib.filterAttrs (_: lib.isType "flake")) inputs);

  # Set environment variables.
  home.sessionVariables = {
    DOCKER_BUILDKIT = "1";
    EDITOR = "code";
  };

  # Register shell aliases.
  home.shellAliases = {
    d = "docker run --rm -it";
    k = "kubectl";
    g = "git";
    ll = "ls -al";
    clean = "git clean -xd --interactive";
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
    py = "steam-run $(which python)";
  };

  # Enable user programs.
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
      gitCredentialHelper.enable = false;
    };
  };

  # Include additional user packages.
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
    fx
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
    jupyter
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
    nix-diff
    nix-info
    nix-init
    nix-tree
    nixfmt
    nixos-rebuild
    nixpkgs-fmt
    nixpkgs-review
    nmap
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
    pyenv
    python3Packages.tensorboard
    pyupgrade
    rclone
    restic
    ripgrep
    rsync
    runme
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
    typst
    visidata
    wget
    yarn
  ];

  # Enable pyenv integration.
  programs.pyenv.enable = true;

  # Discover fonts installed through home.packages.
  fonts.fontconfig.enable = true;

  # Check for release version mismatch between Home Manager and nixpkgs.
  home.enableNixpkgsReleaseCheck = true;

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "22.11"; # Please read the comment before changing.
}
