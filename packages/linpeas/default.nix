{
  stdenv,
  fetchurl,
  ...
}:

stdenv.mkDerivation {
  name = "linpeas";
  src = fetchurl {
    url = "https://github.com/peass-ng/PEASS-ng/releases/latest/download/linpeas.sh";
    hash = "sha256-Dqfpzl/MpGS1mYy3OTDjZkfr+bOFkP4lC71WZP6GcKU=";
  };
  dontUnpack = true;
  installPhase = ''
    mkdir -p $out/bin
    cp $src $out/bin/linpeas
    chmod +x $out/bin/linpeas
  '';
}
