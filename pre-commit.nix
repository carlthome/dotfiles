{ pre-commit-hooks, system, ... }: {
  pre-commit-check = pre-commit-hooks.lib.${system}.run {
    src = ./.;
    hooks = {
      actionlint.enable = true;
      nixpkgs-fmt.enable = true;
      prettier = {
        enable = true;
        excludes = [ "flake.lock" ];
      };
      shellcheck.enable = true;
      shfmt.enable = true;
    };
  };
}
