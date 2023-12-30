{ config, pkgs, ... }: {

  # Enable flakes and new commands.
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Configure trusted binary caches.
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

  # Enable automatic garbage collection.
  nix.gc = {
    automatic = true;
    options = "--delete-older-than 30d";
  };

  # Make sure packages share files by scanning for duplicates.
  nix.settings.auto-optimise-store = true;

  # Limit resources used by Nix to not make the system irresponsive during upgrades.
  nix.settings.cores = 1;
  nix.settings.max-jobs = 1;
}
