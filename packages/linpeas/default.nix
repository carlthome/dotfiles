{
  lib,
  writeScriptBin,
  fetchurl,
  ...
}:

writeScriptBin "linpeas" (
  builtins.readFile (fetchurl {
    url = "https://github.com/peass-ng/PEASS-ng/releases/latest/download/linpeas.sh";
    hash = "sha256-18DJUw7tYnvu4IM217OMtE9MDfep66O6GyopDZZr4W8=";
  })
)
