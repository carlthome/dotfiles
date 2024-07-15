{ pkgs, ... }: {
  networking.hostName = "mbp";
  environment.etc.hosts = {
    text = ''
      127.0.0.1	      localhost
      255.255.255.255 broadcasthost
      ::1             localhost
      127.0.0.1       kubernetes.default.svc.cluster.local
    '';
  };
}
