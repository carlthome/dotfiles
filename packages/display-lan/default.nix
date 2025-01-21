{ pkgs, nmap, arp-scan, nettools, gnugrep, lsof, ... }: pkgs.writeShellApplication {
  name = "display-lan";
  runtimeInputs = [ nmap arp-scan nettools gnugrep lsof ];
  text = builtins.readFile ./script.sh;
}
