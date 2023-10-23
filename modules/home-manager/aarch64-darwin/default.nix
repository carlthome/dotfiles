{ config, pkgs, lib, ... }: {
  nixpkgs.config = {
    allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
      "vscode"
    ];
  };

  home.packages = with pkgs; [
    colima
  ];

  home.sessionVariables = {
    # TODO Uncomment once done with trying OrbStack.
    #DOCKER_HOST = "unix://$HOME/.colima/default/docker.sock";
  };
}
