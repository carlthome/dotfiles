{ pkgs, lib, ... }: {
  nix.settings.substituters = [
    "https://cache.nixos.org/"
    "https://cuda-maintainers.cachix.org"
    "https://nixpkgs-unfree.cachix.org"
  ];
  nix.settings.trusted-public-keys = [
    "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
    "nixpkgs-unfree.cachix.org-1:hqvoInulhbV4nJ9yJOEr+4wxhDV4xq2d1DK7S6Nj6rs="
  ];
}
