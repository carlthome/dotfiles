{ nixpkgs-unstable, ... }:
{
  nixpkgs-unstable = import ./nixpkgs-unstable.nix { inherit nixpkgs-unstable; };
  modules-closure = import ./modules-closure.nix { };
  accelerate-mps-fix = import ./accelerate-mps-fix.nix;
}
