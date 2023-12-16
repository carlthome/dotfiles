{ config, pkgs, ... }: {
  nix.settings.substituters = [
    "https://carlthome.cachix.org"
    "https://numtide.cachix.org"
  ];

  nix.settings.trusted-public-keys = [
    "carlthome.cachix.org-1:BHerYg0J5Qv/Yw/SsxqPBlTY+cttA9axEsmrK24R15w="
    "numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE="
  ];

  # Configure Nix program itself.
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
  };

  # Enable automatic garbage collection.
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  # Auto-update system packages periodically.
  system.autoUpgrade = {
    enable = true;
    flake = "nixpkgs";
  };

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
    systemPackages = with pkgs; [ vim ];
    shellAliases = {
      switch-system = "nixos-rebuild switch --flake .";
      list-generations = "nix-env --list-generations";
    };
    shells = [ pkgs.fish ];
    variables = {
      EDITOR = "vim";
    };
  };

  # Provide suggestions of packages to install when a command is not found.
  programs.command-not-found.enable = true;
}
