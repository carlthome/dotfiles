{ pre-commit-hooks, system, ... }:
{
  pre-commit-check = pre-commit-hooks.lib.${system}.run {
    src = ./.;
    hooks = {
      actionlint.enable = true;
      nixfmt-rfc-style.enable = true;
      prettier = {
        enable = true;
        excludes = [
          "flake.lock"
        ];
      };
      shellcheck = {
        enable = true;
        excludes = [
          ".envrc"
        ];
      };
      shfmt.enable = true;
    };
  };
}
