{ pkgs, self, ... }: {
  type = "app";
  program =
    let src = builtins.readFile ./script.sh;
    in (pkgs.writeScript "script" src).outPath;
}
