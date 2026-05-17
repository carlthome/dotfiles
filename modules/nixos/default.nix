{ ... }:
{
  desktop = import ./desktop.nix;
  server = import ./server.nix;
  cuda = import ./cuda.nix;
  default = import ./configuration.nix;
}
