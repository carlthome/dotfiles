{
  description = "A very basic flake";

  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system}; in
      rec {
        packages.hello = pkgs.hello;
        defaultPackage = packages.hello;

        # TODO Let shell.nix still be around for nix-shell legacy usage.
        #devShells.default = import ./shell.nix { inherit pkgs; };
        devShells.default = with pkgs;
          let
            python = python3.withPackages (p: with p; [
              #black
              #jax
              #jaxlib
              #librosa
              #matplotlib
              #mypy
              #pytorch
              #tensorflow
              flake8
              ipython
              isort
              numpy
              opencv
              pandas
              pip
              scipy
              setuptools
            ]);
          in
          pkgs.mkShell {
            buildInputs = [
              #pre-commit
              act
              awscli
              cargo
              ffmpeg
              git
              github-cli
              google-cloud-sdk
              jupyter
              jq
              libsndfile
              nixpkgs-fmt
              nodejs
              nodePackages.npm
              nodePackages.prettier
              opencv
              poetry
              python
              pdfgrep
              rustup
              sox
              starship
              shellcheck
              vim
            ];
            shellHook = ''
              echo "Hello $(whoami)!"
            '';
          };
      }
    );
}
