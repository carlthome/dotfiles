{ pkgs, ... }:

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
    redhat.vscode-yaml
    rust-lang.rust-analyzer
    stkb.rewrap
    svelte.svelte-vscode
    tamasfe.even-better-toml
    tomoki1207.pdf
    twxs.cmake
    #TODO Broken on darwin.
    #ms-vscode.cpptools
    #ms-vsliveshare.vsliveshare
  ];
  marketplaceExtensions =
    (pkgs.vscode-utils.extensionsFromVscodeMarketplace [
      # TODO This extension is too buggy.
      # {
      #   name = "runme";
      #   publisher = "stateful";
      #   version = "3.6.1";
      #   sha256 = "sha256-SJzSckY61vObVq8FE0kv4MrtKFJqx8eAHCzd9/k65+M=";
      # }
      {
        name = "python-environment-manager";
        publisher = "donjayamanne";
        version = "1.2.4";
        sha256 = "1jvuoaP+bn8uR7O7kIDZiBKuG3VwMTQMjCJbSlnC7Qo=";
      }
      {
        name = "andromeda";
        publisher = "EliverLara";
        version = "1.8.1";
        sha256 = "O0WIewAExQTLlwstAglx1/6ukLntAqXxOEKRzw/5wKA=";
      }
      {
        name = "noctis";
        publisher = "liviuschera";
        version = "10.40.0";
        sha256 = "UbGWorOVeitE9Q6tZ18h9K4Noz5Y3oaiuYaJtPzcwOc=";
      }
      {
        name = "sorcerer";
        publisher = "MarkThomasMiller";
        version = "0.1.3";
        sha256 = "QvyIsRQF6CYvSH6LxRD2YzVBtlGQl6V+lXOaqGe23zU=";
      }
      {
        name = "dragan-color-theme";
        publisher = "Miladfathy";
        version = "2.0.8";
        sha256 = "oeAzHODbKif8ZUnn8qUlLT2M2tUfEEGaGQ1Kkuagni4=";
      }
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
marketplaceExtensions ++ packagedExtensions
