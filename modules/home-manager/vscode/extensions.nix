{ pkgs, ... }:

let
  packagedExtensions = with pkgs.vscode-extensions; [
    davidanson.vscode-markdownlint
    dbaeumer.vscode-eslint
    esbenp.prettier-vscode
    github.copilot
    github.github-vscode-theme
    github.vscode-github-actions
    github.vscode-pull-request-github
    gitlab.gitlab-workflow
    golang.go
    hashicorp.terraform
    jnoortheen.nix-ide
    mikestead.dotenv
    ms-azuretools.vscode-docker
    ms-kubernetes-tools.vscode-kubernetes-tools
    ms-python.black-formatter
    ms-python.isort
    ms-python.python
    ms-python.vscode-pylance
    ms-toolsai.jupyter
    ms-toolsai.vscode-jupyter-slideshow
    ms-vscode-remote.remote-containers
    ms-vscode-remote.remote-ssh
    ms-vscode.cmake-tools
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
  marketplaceExtensions = (pkgs.vscode-utils.extensionsFromVscodeMarketplace [
    {
      name = "flake8";
      publisher = "ms-python";
      version = "2023.6.0";
      sha256 = "Hk7rioPvrxV0zMbwdighBAlGZ43rN4DLztTyiHqO6o4=";
    }
    {
      name = "debugpy";
      publisher = "ms-python";
      version = "2023.3.13121011";
      sha256 = "owYUEyQl2FQytApfuI97N4y9p7/dL0lu6EBk/AzSMjw=";
    }
    {
      name = "git-line-blame";
      publisher = "carlthome";
      version = "0.8.0";
      sha256 = "voMnpi4XcclmW49/HeKUctDGOYAdLp8dio5nr7kEMpg=";
    }
    {
      name = "copilot-chat";
      publisher = "github";
      version = "0.8.0";
      sha256 = "IJ75gqsQj0Ukjlrqevum5AoaeZ5vOfxX/4TceXe+EIg=";
    }
    {
      name = "datawrangler";
      publisher = "ms-toolsai";
      version = "0.26.0";
      sha256 = "9Diu3mb7VjB4MXWb5+gYnEjXJiAzSww4Ij3VDb4l77w=";
    }
    {
      name = "vscode-dotnet-runtime";
      publisher = "ms-dotnettools";
      version = "2.0.1";
      sha256 = "tyPHE3YAKDx6SW/qguafe5OmxDKLPfQHXjsDQaGONFg=";
    }
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
      sha256 = "VCch8H//o3pTw3IRqGmCN+sz1G0DDPvbzqkabPTXT5Q=";
    }
    {
      name = "dragan-color-theme";
      publisher = "Miladfathy";
      version = "2.0.8";
      sha256 = "oeAzHODbKif8ZUnn8qUlLT2M2tUfEEGaGQ1Kkuagni4=";
    }
  ]) ++ [
    ((pkgs.vscode-utils.extensionFromVscodeMarketplace
      {
        name = "cloudcode";
        publisher = "googlecloudtools";
        version = "2.2.1";
        sha256 = "PRGtxcN98DisCPAoRdgDQYFwYo/LEPflx55YDe08C+k=";
      }).overrideAttrs (_: { sourceRoot = "extension"; }))
  ];
in
marketplaceExtensions ++ packagedExtensions
