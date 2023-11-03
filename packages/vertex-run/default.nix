# Run a Python package in Vertex AI as a Docker image.
#
# Usage: vertex-run .#python-package
#
{ pkgs ? import <nixpkgs> { }, ... }:

let
  image = pkgs.dockerTools.buildImage {
    name = "hello";
    tag = "latest";
    created = "now";
    copyToRoot = pkgs.buildEnv {
      name = "image-root";
      paths = [ pkgs.hello ];
      pathsToLink = [ "/bin" ];
    };
    config.Cmd = [ "/bin/hello" ];
  };
in
pkgs.writeShellApplication {
  name = "vertex-run";
  runtimeInputs = [
    image
    pkgs.google-cloud-sdk
    pkgs.docker
  ];
  text = ''
    echo "$2"

    docker load < ${image}
    #docker push

    gcloud ai custom-jobs create --worker-pool-spec=replica-count=1,machine-type=n1-standard-4,container-image-uri=gcr.io/ucaip-test/ucaip-training-test
  '';
}
