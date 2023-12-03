{ config, pkgs, lib, ... }: {
  nixpkgs.config = {
    allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
      "vscode"
      "terraform"
      "roomeqwizard"
    ];
  };

  home.packages = with pkgs; [
    colima
    roomeqwizard
  ];

  home.sessionVariables = {
    # TODO Uncomment once done with trying OrbStack.
    #DOCKER_HOST = "unix://$HOME/.colima/default/docker.sock";
  };
}
