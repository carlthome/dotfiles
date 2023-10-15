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

  fonts.fontconfig.enable = true;
  home.enableNixpkgsReleaseCheck = true;
  home.stateVersion = "22.11";
}
