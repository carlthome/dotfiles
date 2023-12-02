{ nixpkgs-unstable, ... }: {
  vscode-unstable = import ./vscode-unstable.nix { inherit nixpkgs-unstable; };
}
