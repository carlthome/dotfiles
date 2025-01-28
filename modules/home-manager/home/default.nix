{
  config,
  pkgs,
  lib,
  self,
  ...
}@inputs:
{

  # Add each flake input to registry.
  nix.registry = (lib.mapAttrs (_: flake: { inherit flake; })) (
    (lib.filterAttrs (_: lib.isType "flake")) inputs
  );

  # Set environment variables.
  home.sessionVariables = {
    EDITOR = "~/.nix-profile/bin/vim";
    VISUAL = "~/.nix-profile/bin/code";
    #TODO This screws up SSH on macOS.
    #SHELL = "fish";
  };

  # Register shell aliases.
  home.shellAliases = {
    d = "docker run -v $(pwd):$(pwd) -w $(pwd) --rm -it";
    k = "kubectl";
    g = "git";
    gg = "git grep --line-number --column";
    ll = "ls -al";
    pc = "pre-commit run --all";
    clean = "git clean -xd --interactive";
    commit = "git commit --patch";
    rebase = "git rebase --interactive";
    restore = "git restore --patch --source";
    push = "git push";
    pull = "git pull";
    build = "nix build --print-build-logs";
    run = "nix run";
    develop = "nix develop";
    edit = "nix edit";
    search = "nix search";
    update = "nix flake update --commit-lock-file";
    switch-home = "home-manager switch --flake .";
    pylab = "${self.packages.${pkgs.system}.pylab}/bin/jupyter";
    docker-cpu = "docker ps -q | xargs docker stats --no-stream";
    pods = "${self.packages.${pkgs.system}.k8s-pods-logs}/bin/k8s-pods-logs";
    icat = "kitten icat";
  };

  # Default startup setup when starting an IPython session.
  home.file.".ipython/profile_default/startup/setup.ipy".text = ''
    %pylab inline
    %load_ext autoreload
    %autoreload 2
  '';

  # Enable user programs.
  programs = {
    home-manager.enable = true;
    man.enable = true;
    fish.enable = true;
    zsh = {
      enable = true;
      autocd = true;
    };
    awscli.enable = true;
    yt-dlp.enable = true;
    nushell.enable = true;
    bash = {
      enable = true;
      shellOptions = [
        "autocd"
        "cdspell"
        "dirspell"
        "checkhash"
        "checkjobs"
        "extglob"
        "globstar"
        "histappend"
      ];
    };
    nnn.enable = true;
    starship = {
      enable = true;
      enableTransience = true;
    };
    direnv = {
      enable = true;
      nix-direnv.enable = true;
      config = {
        global.hide_env_diff = true;
      };
    };
    gpg.enable = true;
    gitui.enable = true;
    pyenv.enable = true;
    bun.enable = true;
    fd.enable = true;
    nh.enable = true;
    poetry.enable = true;
    alacritty.enable = true;
  };

  # Include additional user packages.
  home.packages = with pkgs; [
    act
    actionlint
    asdf-vm
    autoflake
    autossh
    black
    buildah
    buildkit
    cachix
    cmake
    comma
    commitizen
    cookiecutter
    copier
    coreutils-full
    ctags
    curl
    delve
    dive
    docker-client
    docker-slim
    duckdb
    electrum
    fantasque-sans-mono
    fd
    fdupes
    ffmpeg-full
    fx
    gcc
    gnumake
    go
    go-tools
    gopls
    hadolint
    htop
    iftop
    isort
    jetbrains-mono
    jq
    jupyter
    k9s
    keepassxc
    kind
    kubectl
    kubectx
    kubernetes-helm
    lame
    lynis
    maple-mono
    mdcat
    minikube
    mypy
    ncdu_1
    nettools
    nil
    ninja
    nix-diff
    nix-info
    nix-init
    nix-tree
    nixfmt-rfc-style
    nixos-rebuild
    nixpkgs-review
    nmap
    nodejs
    nodePackages.npm
    nodePackages.prettier
    opusTools
    pandoc
    pass
    pdfgrep
    pdm
    phoronix-test-suite
    pijul
    pipenv
    pipx
    podman
    postgresql
    pre-commit
    pyenv
    python3Packages.tensorboard
    pyupgrade
    rclone
    restic
    ripgrep
    rsync
    rubberband
    runme
    rustup
    shellcheck
    skaffold
    snyk
    sops
    sox
    spr
    sqlitebrowser
    syft
    terraform
    timidity
    tree
    typst
    uv
    victor-mono
    visidata
    vorbis-tools
    wget
    wrk
    yarn
    yq
    (google-cloud-sdk.withExtraComponents (
      with google-cloud-sdk.components;
      [
        gke-gcloud-auth-plugin
      ]
    ))
  ];

  # Avoid having ncdu look through cloud storage and network shares.
  xdg.configFile."ncdu/config".source = (
    pkgs.writeText "ncdu-config" ''
      --one-file-system
    ''
  );

  # Discover fonts installed through home.packages.
  fonts.fontconfig.enable = true;

  # Check for release version mismatch between Home Manager and nixpkgs.
  home.enableNixpkgsReleaseCheck = true;

  # TODO Remove after testing.
  launchd.agents.lunchtime = {
    enable = true;
    config = {
      ProgramArguments = [
        "/usr/bin/say"
        "lunchtime"
      ];
      StandardErrorPath = "/tmp/lunchtime.err";
      StandardOutPath = "/tmp/lunchtime.out";
      StartCalendarInterval = [
        {
          Hour = 12;
          Minute = 0;
        }
      ];
    };
  };

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "22.11"; # Please read the comment before changing.
}
