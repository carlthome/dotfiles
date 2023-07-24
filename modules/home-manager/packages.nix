{ pkgs, ... }: {
  home.packages = with pkgs; [
    act
    actionlint
    asdf-vm
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
    minikube
    mypy
    ncdu
    nil
    ninja
    nixfmt
    nixpkgs-fmt
    nixpkgs-review
    nodejs
    nodePackages.npm
    nodePackages.prettier
    pass
    pdfgrep
    pipenv
    podman
    poetry
    postgresql
    pre-commit
    python3
    pipx
    pdm
    python3Packages.pip
    python3Packages.tensorboard
    pyupgrade
    rclone
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
