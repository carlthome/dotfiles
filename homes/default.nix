{ home-manager, nixpkgs, nixpkgs-unstable, nix-index-database, system, self, ... }@inputs:
let
  overlays = [
    (self: super:
      let
        pkgs = import nixpkgs-unstable {
          inherit super system;
          config.allowUnfreePredicate = pkg: builtins.elem (nixpkgs.lib.getName pkg) [
            "vscode"
            "vscode-extension-github-copilot"
            "vscode-extension-MS-python-vscode-pylance"
            "vscode-extension-ms-vscode-cpptools"
            "vscode-extension-ms-vscode-remote-remote-ssh"
            "vscode-extension-ms-vsliveshare-vsliveshare"
            "vscode-extension-ms-vscode-remote-remote-containers"
          ];
        };
      in
      {
        vscode = pkgs.vscode;
        vscode-extensions = pkgs.vscode-extensions;
      }
    )
  ];

  names = builtins.attrNames (builtins.readDir ./.);
  mkHome = name: home-manager.lib.homeManagerConfiguration {
    pkgs = import nixpkgs {
      inherit system;
      inherit overlays;
    };
    modules = [
      ./${name}/home.nix
      nix-index-database.hmModules.nix-index
      self.homeModules.home
      self.homeModules.${system}
    ];
    extraSpecialArgs = inputs;
  };
in
nixpkgs.lib.genAttrs names mkHome
