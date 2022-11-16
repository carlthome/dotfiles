{ pkgs, username, ... }: {
  # TODO MacOS specifics here.
  home.packages = with pkgs; [
    podman
    podman-compose
    qemu
  ];
  home.sessionVariables = {
    DOCKER_HOST = "unix:///Users/${username}/.local/share/containers/podman/machine/podman-machine-default/podman.sock";
  };
}
