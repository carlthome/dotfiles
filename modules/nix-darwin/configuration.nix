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
  security.pam.services.sudo_local.touchIdAuth = true;

  # Let nix-darwin create /etc/* configs to load itself.
  programs.fish.enable = true;
  programs.bash.enable = true;
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    enableSyntaxHighlighting = true;
  };

  # Deduplicate files in the nix store.
  nix.optimise.automatic = true;

  # TODO Enable sandboxing.
  nix.settings.sandbox = false;

  # Global shell aliases for all users.
  environment.shellAliases = {
    show-system = "nix derivation show /run/current-system";
    switch-system = "nh darwin switch .";
    list-generations = "nix-env --list-generations";
  };
}
