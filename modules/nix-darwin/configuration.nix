{ pkgs, ... }: {

  nix.settings.substituters = [
    "https://nixpkgs-unfree.cachix.org"
    "https://numtide.cachix.org"
    "https://carlthome.cachix.org"
  ];

  nix.settings.trusted-public-keys = [
    "nixpkgs-unfree.cachix.org-1:hqvoInulhbV4nJ9yJOEr+4wxhDV4xq2d1DK7S6Nj6rs="
    "numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE="
    "carlthome.cachix.org-1:BHerYg0J5Qv/Yw/SsxqPBlTY+cttA9axEsmrK24R15w="
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

  # Enable sandboxing.
  nix.settings.sandbox = false;

  # Global shell aliases for all users.
  environment.shellAliases = {
    switch-system = "darwin-rebuild switch --flake .";
    list-generations = "nix-env --list-generations";
  };

  system.defaults = {
    trackpad.Clicking = false;
    dock.autohide = true;
  };

  # https://medium.com/@zmre/nix-darwin-quick-tip-activate-your-preferences-f69942a93236
  system.activationScripts.postUserActivation.text = ''
    /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
  '';

}
