{ pkgs, ... }: {
  home.packages = with pkgs; [
    act
    asdf-vm
    awscli
    black
    buildah
    buildkit
    cachix
    cmake
    cookiecutter
    coreutils-full
    curl
    distrobox
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
    hadolint
    isort
    jq
    jujutsu
    jupyter
    keepassxc
    kind
    kubectl
    kubectx
    kubernetes-helm
    minikube
    mypy
    ncdu
    nil
    ninja
    nixfmt
    nixpkgs-fmt
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
    terraform
    tree
    visidata
    wget
    yarn
  ];
}
