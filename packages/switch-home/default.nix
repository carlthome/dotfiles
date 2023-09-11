{ pkgs, self, home-manager, ... }: pkgs.writeShellApplication {
  name = "switch-home";
  runtimeInputs = [ home-manager.packages.${pkgs.system}.home-manager ];
  text = "home-manager switch --flake ${self}";
}
