{ config, pkgs, ... }:
{
  home.username = "carl";
  home.homeDirectory = "/home/carl";
  nixpkgs.config = { 
    allowUnfree = true;
    allowUnfreePredicate = (pkg: true);
    cudaSupport = true;
    cudnnSupport = true;
  };
}
