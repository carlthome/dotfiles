{ pkgs, ... }: {

  # Install packages in system profile.
  environment.systemPackages = with pkgs; [
    vim
    git
    clang
    gcc-unwrapped
    gnumake
    unixtools.watch
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

  # Recreate /run/current-system symlink after boot.
  services.activate-system.enable = true;

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;
  nix.package = pkgs.nix;

  # Enable sandboxing.
  nix.settings.sandbox = false;

  # Global shell aliases for all users.
  environment.shellAliases = {
    switch-system = "darwin-rebuild switch --flake .";
    list-generations = "nix-env --list-generations";
  };

  # Configure macOS settings.
  system.defaults = {
    trackpad.Clicking = false;
    dock.autohide = true;
  };

  # https://medium.com/@zmre/nix-darwin-quick-tip-activate-your-preferences-f69942a93236
  system.activationScripts.postUserActivation.text = ''
    /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
  '';
}
