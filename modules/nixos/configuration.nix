{ config, pkgs, ... }:
{

  # Auto-upgrade NixOS hosts periodically.
  system.autoUpgrade = {
    enable = true;
    flake = "github:carlthome/dotfiles";
  };

  # Auto-deduplicate files in the store.
  nix.settings.auto-optimise-store = true;

  # Select locale, time zone and default keyboard layout.
  console.keyMap = "sv-latin1";
  time.timeZone = "Europe/Stockholm";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "sv_SE.UTF-8";
    LC_IDENTIFICATION = "sv_SE.UTF-8";
    LC_MEASUREMENT = "sv_SE.UTF-8";
    LC_MONETARY = "sv_SE.UTF-8";
    LC_NAME = "sv_SE.UTF-8";
    LC_NUMERIC = "sv_SE.UTF-8";
    LC_PAPER = "sv_SE.UTF-8";
    LC_TELEPHONE = "sv_SE.UTF-8";
    LC_TIME = "sv_SE.UTF-8";
  };

  # Set default shell for all users.
  users.defaultUserShell = pkgs.fish;
  programs.fish.enable = true;

  # Set a basic default environment for all users.
  environment = {
    systemPackages = with pkgs; [
      vim
      htop
      ncdu
      tmux
    ];
    shellAliases = {
      show-system = "nix derivation show /run/current-system";
      switch-system = "nh os switch .";
      list-generations = "nix-env --list-generations";
    };
    shells = [ pkgs.fish ];
    variables = {
      EDITOR = "vim";
      SHELL = "fish";
    };
  };
}
