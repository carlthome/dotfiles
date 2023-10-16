{ home-manager, nixpkgs, nixpkgs-unstable, nix-index-database, system, self, ... }@inputs:
let
  overlays = [
    (self: super:
      let
        pkgs = import nixpkgs-unstable {
          inherit super system;
          config.allowUnfreePredicate = pkg: builtins.elem (nixpkgs.lib.getName pkg) [
            "vscode"
          ];
        };
      in
      {
        vscode = pkgs.vscode;
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
