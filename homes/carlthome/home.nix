{ config, pkgs, lib, self, ... }: {
  imports = with self.homeModules; [
    vscode
    vim
    neovim
    emacs
    git
    github
    tmux
    fzf
    auto-upgrade
    git-refresh
  ];

  home.username = "carlthome";
  home.homeDirectory = if pkgs.stdenv.hostPlatform.isDarwin then "/Users/carlthome" else "/home/carlthome";
  programs.git.userName = "Carl Thomé";
  programs.git.userEmail = "carl.thome@epidemicsound.com";
  home.sessionPath = [
    "$HOME/miniconda3/bin"
  ];
  home.file.".condarc" = {
    text = ''
      channels:
        - conda-forge
        - defaults
        - pytorch
      channel_priority: strict
      auto_activate_base: false
      default_threads: 4
    '';
    executable = false;
  };
}
