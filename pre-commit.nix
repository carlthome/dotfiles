{ pre-commit-hooks, system, ... }:
{
  pre-commit-check = pre-commit-hooks.lib.${system}.run {
    src = ./.;
    hooks = {
      actionlint.enable = true;
      nixfmt.enable = true;
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
      promtool-rules = {
        enable = true;
        files = "systems/pi/prometheus/rules.yml";
      };
    };
  };
}
