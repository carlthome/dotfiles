{ pkgs, ... }:
((pkgs.writeShellApplication
  {
    name = "auto-upgrade";
    runtimeInputs = with pkgs; [ nix home-manager ];
    text = "home-manager switch --refresh --flake github:carlthome/dotfiles";
  }
).outPath + "/bin/auto-upgrade")
