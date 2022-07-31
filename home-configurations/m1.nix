{ config, pkgs, ... }:
{
  home.username = "Carl";
  home.homeDirectory = "/Users/Carl";
  nixpkgs.config = {
    allowUnfree = true;
  };
}
