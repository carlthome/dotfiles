{ ... }: {
  default = import ./home.nix;
  aarch64-darwin = import ./aarch64-darwin.nix;
  x86_64-linux = import ./x86_64-linux.nix;
}
