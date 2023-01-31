{ pre-commit-hooks, system, ... }: pre-commit-hooks.lib.${system}.run {
  src = ./.;
  hooks = {
    actionlint.enable = true;
    nixpkgs-fmt.enable = true;
    prettier.enable = true;
    shellcheck.enable = true;
    shfmt.enable = true;
    statix.enable = true;
  };
}
