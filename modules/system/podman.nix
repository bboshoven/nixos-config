{ config, pkgs, ... }: {

  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
  };

  virtualisation.containers.registries.search = [
    "docker.io"
    "registry.kp.boshoven.dev"
  ];

#  virtualisation.containers = {
#    enable = true;
#    containersConf.settings = {
#      containers = {
#        dns_servers = [
#          "1.1.1.1"
#          "8.8.8.8"
#        ];
#      };
#    };
#  };

}
