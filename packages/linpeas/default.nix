{
  stdenv,
  fetchurl,
  ...
}:

stdenv.mkDerivation {
  name = "linpeas";
  src = fetchurl {
    url = "https://github.com/peass-ng/PEASS-ng/releases/latest/download/linpeas.sh";
    hash = "sha256-0pCcSlBpBhgVIzRNmjNoBlftUIZj0gRLXvj7haKg/D4=";
  };
  dontUnpack = true;
  installPhase = ''
    mkdir -p $out/bin
    cp $src $out/bin/linpeas
    chmod +x $out/bin/linpeas
  '';
}
