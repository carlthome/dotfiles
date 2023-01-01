{ config, pkgs, ... }: {
  home.packages = with pkgs; [
    colima
  ];
  home.sessionVariables = {
    DOCKER_HOST = "unix://$HOME/.colima/default/docker.sock";
  };
}
