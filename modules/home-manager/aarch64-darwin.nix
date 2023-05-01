{ config, pkgs, lib, ... }: {
  nixpkgs.config = {
    allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
    ];
  };
  home.packages = with pkgs; [
    colima
  ];
  home.sessionVariables = {
    DOCKER_HOST = "unix://$HOME/.colima/default/docker.sock";
  };
}
