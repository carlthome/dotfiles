{ config, pkgs, lib, self, ... }: {
  imports = with self.homeModules; [
    vscode
    vim
    neovim
    emacs
    git
    github
    tmux
    auto-upgrade
    git-refresh
  ];

  home.username = "carlthome";
  home.homeDirectory = if pkgs.stdenv.hostPlatform.isDarwin then "/Users/carlthome" else "/home/carlthome";
  programs.git.userName = "Carl Thomé";
  programs.git.userEmail = "carl.thome@epidemicsound.com";
}
