{ nixpkgs-unstable, ... }: {
  vscode-unstable = import ./vscode-unstable.nix { inherit nixpkgs-unstable; };
  modules-closure = import ./modules-closure.nix { };
}
