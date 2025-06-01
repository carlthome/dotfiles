{ pkgs, ... }:
{

  # Install packages in system profile.
  environment.systemPackages = with pkgs; [
    clang
    coreutils
    findutils
    gcc-unwrapped
    git
    gnumake
    unixtools.watch
    vim
  ];

  # Enable fingerprint scanner for authentication.
  security.pam.enableSudoTouchIdAuth = true;

  # Let nix-darwin create /etc/* configs to load itself.
  programs.fish.enable = true;
  programs.bash.enable = true;
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    enableSyntaxHighlighting = true;
  };

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;
  nix.package = pkgs.nix;

  # Deduplicate files in the nix store.
  nix.optimise.automatic = true;

  # Enable sandboxing.
  nix.settings.sandbox = "relaxed";

  # Global shell aliases for all users.
  environment.shellAliases = {
    show-system = "nix derivation show /run/current-system";
    switch-system = "sudo darwin-rebuild switch --flake .";
    list-generations = "nix-env --list-generations";
  };

  # Configure macOS settings.
  system.defaults = {
    trackpad = {
      Clicking = false;
    };
    dock = {
      autohide = true;
      orientation = "bottom";
      show-process-indicators = false;
      show-recents = false;
      static-only = true;
    };
    finder = {
      AppleShowAllExtensions = true;
      ShowPathbar = true;
      FXEnableExtensionChangeWarning = false;
    };
  };

  # https://medium.com/@zmre/nix-darwin-quick-tip-activate-your-preferences-f69942a93236
  system.activationScripts.postUserActivation.text = ''
    /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
  '';
}
