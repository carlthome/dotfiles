{
  lib,
  writeScriptBin,
  fetchurl,
  ...
}:

writeScriptBin "linpeas" (
  builtins.readFile (fetchurl {
    url = "https://github.com/peass-ng/PEASS-ng/releases/latest/download/linpeas.sh";
    hash = "sha256-6DcTBxZk2Lb+65yULwXco7pJUaxVdD2663mTP0coln0=";
  })
)
