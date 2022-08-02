{ config, pkgs, ... }:
{
  nixpkgs.config = { 
    allowUnfree = true;
    allowUnfreePredicate = (pkg: true);
    cudaSupport = true;
    cudnnSupport = true;
  };
}
