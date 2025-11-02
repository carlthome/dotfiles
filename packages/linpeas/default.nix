{
  lib,
  writeScriptBin,
  fetchurl,
  ...
}:

writeScriptBin "linpeas" (
  builtins.readFile (fetchurl {
    url = "https://github.com/peass-ng/PEASS-ng/releases/latest/download/linpeas.sh";
    hash = "sha256-DGAvZN21bleXCP2tSxI4hzyf6Msbfq22yy4iyWh1dMg=";
  })
)
