{
  lib,
  writeScriptBin,
  fetchurl,
  ...
}:

writeScriptBin "linpeas" (
  builtins.readFile (fetchurl {
    url = "https://github.com/peass-ng/PEASS-ng/releases/latest/download/linpeas.sh";
    hash = "sha256-AuqPIhpQ0FViMcbcPFPol1W+NWON/J8ybLhs7xIXMaU=";
  })
)
