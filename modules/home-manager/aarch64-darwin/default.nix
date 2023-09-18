{ config, pkgs, lib, ... }: {
  nixpkgs.config = {
    allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
      "vscode"
      "vscode-extension-github-copilot"
      "vscode-extension-MS-python-vscode-pylance"
      "vscode-extension-ms-vscode-remote-remote-ssh"
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
