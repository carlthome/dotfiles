{ config, pkgs, ... }:
let
  user =
    if pkgs.stdenv.isDarwin then
      rec {
        name = "Carl";
        home = "/Users/{name}";
      } else
      rec {
        name = "carlthome";
        home = "/home/{name}";
      };
in
{
  home.username = user.name;
  home.homeDirectory = user.home;
  home.stateVersion = "22.05";

  home.packages = [
    pkgs.google-cloud-sdk
    pkgs.awscli
    pkgs.act
    pkgs.nixpkgs-fmt
  ];

  programs.home-manager.enable = true;

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
  };

  programs.command-not-found.enable = true;

  programs.zsh.enable = true;
  programs.nushell.enable = true;
  programs.bash = {
    enable = true;
    shellAliases = {
      d = "docker run --rm -it";
      k = "kubectl";
      g = "gcloud beta interactive";
    };
  };
  programs.tmux.enable = true;

  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

  programs.git = {
    enable = true;
    userName = "Carl Thomé";
    userEmail = "carlthome@gmail.com";
  };
  programs.gh.enable = true;
}
