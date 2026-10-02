{
  stdenv,
  fetchurl,
  ...
}:

stdenv.mkDerivation {
  name = "linpeas";
  src = fetchurl {
    url = "https://github.com/peass-ng/PEASS-ng/releases/download/20261002-e8dd81ca/linpeas.sh";
    hash = "sha256:cb466f4e08d5ffed72f0cec5f634b9ee52a79c91d57fa323ff0c45bc76ca3bb3";
  };
  dontUnpack = true;
  installPhase = ''
    mkdir -p $out/bin
    cp $src $out/bin/linpeas
    chmod +x $out/bin/linpeas
  '';
}
