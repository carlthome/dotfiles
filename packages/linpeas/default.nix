{
  stdenv,
  fetchurl,
  ...
}:

stdenv.mkDerivation {
  name = "linpeas";
  src = fetchurl {
    url = "https://github.com/peass-ng/PEASS-ng/releases/latest/download/linpeas.sh";
    hash = "sha256-iL4ndh7JTHX00UIIq0MaS9wY5V81IfLzOwkuwl5K/mU=";
  };
  dontUnpack = true;
  installPhase = ''
    mkdir -p $out/bin
    cp $src $out/bin/linpeas
    chmod +x $out/bin/linpeas
  '';
}
