{ pre-commit, ... }: pre-commit.run {
  src = ./.;
  hooks = {
    actionlint.enable = true;
    nixpkgs-fmt.enable = true;
    prettier.enable = true;
    shellcheck.enable = true;
    shfmt.enable = true;
  };
}
