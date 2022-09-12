{ config, pkgs, lib, options, specialArgs, modulesPath }: {
  nixpkgs.config = {
    allowUnfree = true;
    allowUnfreePredicate = (pkg: true);
  };

  home = {
    stateVersion = "22.05";
    enableNixpkgsReleaseCheck = true;
    packages = with pkgs; [
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
      gnupg
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
      pipenv
      python3
      python3Packages.pip
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
    sessionVariables = { DOCKER_BUILDKIT = true; };
    shellAliases = {
      d = "docker run --rm -it";
      k = "kubectl";
      g = "gcloud beta interactive";
    };
  };

  fonts.fontconfig.enable = true;

  programs = {
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
      userName = "Carl Thomé";
      userEmail = "carlthome@gmail.com";
      # TODO Play around with non-standard git diff extensions.
      delta.enable = false;
      diff-so-fancy.enable = false;
      difftastic.enable = false;
    };
    gitui.enable = true;
    gh.enable = true;
    vscode = import ./vscode.nix { inherit pkgs; };
  };
}
