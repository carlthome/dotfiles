{
  crate2nix,
  system,
  stdenv,
  ...
}:

let
  rustBuild =
    (crate2nix.tools.${system}.appliedCargoNix {
      name = "rustler-build";
      src = ./.;
    }).rootCrate.build;
in
stdenv.mkDerivation {
  name = "rustler";
  src = ./.;
  buildInputs = [
    rustBuild
  ];
  phases = [ "installPhase" ];
  installPhase = ''
    mkdir -p $out
    cp -r ${rustBuild}/* $out/
    ls resources
    ls $out
    cp -r resources $out
  '';
}
