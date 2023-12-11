{ pkgs, nmap, arp-scan, nettools, gnugrep, ... }: pkgs.writeShellApplication {
  name = "display-lan";
  runtimeInputs = [ nmap arp-scan nettools gnugrep ];
  text = builtins.readFile ./script.sh;
}
