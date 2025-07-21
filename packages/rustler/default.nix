{
  pkgs,
  ...
}:

let
  src = fetchGit {
    url = "https://github.com/carlthome/rustler";
    rev = "2861e2df25a84f2b49f6e5d12ccb10087f03aaf0";
  };
  package = import src { inherit pkgs; };
in
package
