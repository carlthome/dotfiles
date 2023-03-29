{ pkgs, ... }: {
  # Install packages in system profile.
  environment.systemPackages = [
    pkgs.vim
  ];

  # Create /etc/bashrc that loads the nix-darwin environment.
  programs.bash.enable = true;
  programs.bash.enableCompletion = false;

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
  nix.settings.sandbox = true;
}
