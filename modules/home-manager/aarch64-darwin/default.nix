{ config, pkgs, lib, ... }: {
  nixpkgs.config = {
    allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
      "roomeqwizard"
      "terraform"
      "vscode"
    ];
  };

  home.packages = with pkgs; [
    colima
    net-news-wire
    rectangle
    roomeqwizard
    sequelpro
    stats
    #wireshark-qt
  ];

  home.sessionVariables = {
    # TODO Uncomment once done with trying OrbStack.
    #DOCKER_HOST = "unix://$HOME/.colima/default/docker.sock";
  };
}
