{ config, pkgs, ... }: {
  home.username = "Carl";
  home.homeDirectory = "/Users/Carl";
  nixpkgs.config = {
    allowUnfree = true;
    allowUnfreePredicate = (pkg: true);
    virtualisation.docker.enable = true;
  };
}
