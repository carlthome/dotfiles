{ nixpkgs, ... }:
{
  default = import ./configuration.nix { inherit nixpkgs; };
}
