{ config, pkgs, home, ... }: {
  home.stateVersion = "22.05";
  home.enableNixpkgsReleaseCheck = true;
  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    act
    awscli
    black
    cachix
    cargo
    cmake
    coreutils
    curl
    dive
    docker
    docker-compose
    fantasque-sans-mono
    ffmpeg-full
    git
    google-cloud-sdk
    jq
    jupyter
    kind
    libsndfile
    nixpkgs-fmt
    nodejs
    nodePackages.npm
    nodePackages.prettier
    opencv
    pdfgrep
    poetry
    postman
    pre-commit
    rclone
    rsync
    rustc
    shellcheck
    slack
    sox
    sqlitebrowser
    tree
    wget
  ];

  programs.vim.enable = true;

  programs.fish.enable = true;
  programs.zsh.enable = true;
  programs.nushell.enable = true;
  programs.bash.enable = true;
  programs.tmux.enable = true;

  # Enable Docker BuildKit globally by default.
  home.sessionVariables = { DOCKER_BUILDKIT = true; };

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

    # TODO Play around with non-standard git diff extensions.
    delta.enable = false;
    diff-so-fancy.enable = false;
    difftastic.enable = false;
  };

  programs.gitui.enable = true;
  programs.gh.enable = true;

  # TODO GUI programs too?
  #programs.gnome-terminal.enable = true;
  #programs.firefox.enable = true;
  #programs.chromium.enable = true;

  programs.vscode = import ./vscode.nix { inherit pkgs; };
}
