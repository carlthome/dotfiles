{ pkgs, ... }: {
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
    jupyter
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
}
