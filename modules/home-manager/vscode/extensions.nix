{
  pkgs,
  vscode-extensions,
  ...
}:

let
  packagedExtensions = with pkgs.vscode-extensions; [
    charliermarsh.ruff
    davidanson.vscode-markdownlint
    dbaeumer.vscode-eslint
    esbenp.prettier-vscode
    github.copilot
    github.copilot-chat
    github.github-vscode-theme
    github.vscode-github-actions
    github.vscode-pull-request-github
    gitlab.gitlab-workflow
    golang.go
    hashicorp.terraform
    jnoortheen.nix-ide
    mikestead.dotenv
    mkhl.direnv
    ms-azuretools.vscode-docker
    ms-kubernetes-tools.vscode-kubernetes-tools
    ms-python.black-formatter
    ms-python.debugpy
    ms-python.flake8
    ms-python.isort
    ms-python.python
    (if pkgs.config.allowUnfreePredicate "vscode" then ms-python.vscode-pylance else ms-pyright.pyright)
    ms-toolsai.datawrangler
    ms-toolsai.jupyter
    ms-toolsai.jupyter-keymap
    ms-toolsai.jupyter-renderers
    ms-toolsai.vscode-jupyter-cell-tags
    ms-toolsai.vscode-jupyter-slideshow
    ms-vscode-remote.remote-containers
    ms-vscode-remote.remote-ssh
    ms-vscode.cmake-tools
    ms-vscode.live-server
    ms-vscode.makefile-tools
    njpwerner.autodocstring
    pkief.material-icon-theme
    rust-lang.rust-analyzer
    stkb.rewrap
    svelte.svelte-vscode
    tamasfe.even-better-toml
    tomoki1207.pdf
    twxs.cmake
    ms-vscode.cpptools
    ms-vsliveshare.vsliveshare
  ];

  communityPackagedExtensions = with vscode-extensions.vscode-marketplace; [
    # TODO Enable once stable.
    #ms-python.vscode-python-envs
    anthropic.claude-code
    donjayamanne.python-environment-manager
    eliverlara.andromeda
    liviuschera.noctis
    markthomasmiller.sorcerer
    miladfathy.dragan-color-theme
    ms-azuretools.vscode-containers
    wgsl-analyzer.wgsl-analyzer
    # TODO This extension is too buggy.
    #stateful.runme
    openai.chatgpt
  ];

  openVsxExtensions = with vscode-extensions.open-vsx; [
    redhat.vscode-yaml
  ];

  marketplaceExtensions =
    (pkgs.vscode-utils.extensionsFromVscodeMarketplace [
      # {
      #   name = "vscode-python-envs";
      #   publisher = "ms-python";
      #   version = "0.3.10521015";
      #   sha256 = "6YI54XFOIzbozW5ateyuq5t55XuNpnPNKkkGv38Ap3o=";
      # }
      # TODO Extension seems to take a lot of CPU by launching `rg` processes excessively.
      # {
      #   name = "sarif-viewer";
      #   publisher = "MS-SarifVSCode";
      #   version = "3.4.4";
      #   sha256 = "sha256-J7Bqnj9fRP8lcshv9fdK8l6u+i/M1V6XUZf1dMpv/F4=";
      # }
    ])
    ++ [
      (
        (pkgs.vscode-utils.extensionFromVscodeMarketplace {
          name = "cloudcode";
          publisher = "googlecloudtools";
          version = "2.2.1";
          sha256 = "PRGtxcN98DisCPAoRdgDQYFwYo/LEPflx55YDe08C+k=";
        }).overrideAttrs
        (_: {
          sourceRoot = "extension";
        })
      )
    ];
in
builtins.concatLists [
  packagedExtensions
  communityPackagedExtensions
  marketplaceExtensions
  openVsxExtensions
]
