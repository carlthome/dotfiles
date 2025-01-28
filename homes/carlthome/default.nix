{
  home-manager,
  nixpkgs,
  nix-index-database,
  system,
  self,
  nixvim,
  ...
}@inputs:

home-manager.lib.homeManagerConfiguration {
  extraSpecialArgs = inputs;
  pkgs = import nixpkgs {
    inherit system;
    overlays = [
      self.overlays.nixpkgs-unstable
    ];
  };
  modules = [
    ./home.nix
    nix-index-database.hmModules.nix-index
    nixvim.homeManagerModules.nixvim
    self.homeModules.${system}
    self.homeModules.auto-upgrade
    self.homeModules.emacs
    self.homeModules.fzf
    self.homeModules.git
    self.homeModules.git-refresh
    self.homeModules.github
    self.homeModules.helix
    self.homeModules.home
    self.homeModules.kitty
    self.homeModules.neovim
    self.homeModules.tmux
    self.homeModules.vim
    self.homeModules.vscode
    self.homeModules.zed
  ];
}
