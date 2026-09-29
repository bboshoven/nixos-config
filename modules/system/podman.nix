{ config, pkgs, ... }: {

  virtualisation = {
    containers.enable = true;
    podman = {
      enable = true;
      dockerCompat = true;
      defaultPolicy = {
        transport = {
          docker = [ "docker.io" "quay.io" ];
        };
      };
    };
  };

}
