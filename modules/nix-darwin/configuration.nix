{ pkgs, ... }: {

  nix.settings.substituters = [
    "https://carlthome.cachix.org"
    "https://numtide.cachix.org"
  ];

  nix.settings.trusted-public-keys = [
    "carlthome.cachix.org-1:BHerYg0J5Qv/Yw/SsxqPBlTY+cttA9axEsmrK24R15w="
    "numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE="
  ];

  # Link old commands (nix-shell, nix-build, etc.) to use the same nixpkgs as the flake.
  nix.nixPath = [ "nixpkgs=${pkgs.path}" ];

  # Install packages in system profile.
  environment.systemPackages = with pkgs; [
    vim
    git
    clang
    gcc-unwrapped
    gnumake
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

  # Enable automatic garbage collection.
  nix.gc.automatic = true;

  # Automatically deduplicate files.
  nix.settings.auto-optimise-store = true;

  # Auto-upgrade system periodically.
  launchd.user.agents.auto-upgrade = {
    command = "darwin-rebuild switch --flake github:carlthome/dotfiles";
    serviceConfig.KeepAlive = false;
    serviceConfig.RunAtLoad = true;
    serviceConfig.ProcessType = "Background";
    serviceConfig.StartCalendarInterval = [{ Hour = 0; Minute = 0; }];
  };

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
