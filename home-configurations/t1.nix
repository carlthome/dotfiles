{ config, pkgs, ... }:
{
  home.username = "carlthome";
  home.homeDirectory = "/home/carlthome";
  nixpkgs.config = { 
    allowUnfree = true;
    cudaSupport = true;
    cudnnSupport = true;
  };
}
