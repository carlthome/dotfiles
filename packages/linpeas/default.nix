{
  lib,
  writeScriptBin,
  fetchurl,
  ...
}:

writeScriptBin "linpeas" (
  builtins.readFile (fetchurl {
    url = "https://github.com/peass-ng/PEASS-ng/releases/latest/download/linpeas.sh";
    hash = "sha256-0pCcSlBpBhgVIzRNmjNoBlftUIZj0gRLXvj7haKg/D4=";
  })
)
