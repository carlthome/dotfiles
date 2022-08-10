{ config, pkgs, home, ... }: {
  home.stateVersion = "22.05";
  home.enableNixpkgsReleaseCheck = true;
  fonts.fontconfig.enable = true;

  home.packages = with pkgs;
    let python = import ./python.nix;
    in [
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
      fira-code
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
  };

  # TODO Play around with non-standard git diff extensions.
  #programs.git.delta.enable = true;
  #programs.git.diff-so-fancy.enable = true;
  #programs.git.difftastic.enable = true;

  programs.gitui.enable = true;
  programs.gh.enable = true;

  # TODO GUI programs too?
  #programs.gnome-terminal.enable = true;
  #programs.firefox.enable = true;
  #programs.chromium.enable = true;

  programs.vscode = import ./vscode.nix { inherit pkgs; };
}
