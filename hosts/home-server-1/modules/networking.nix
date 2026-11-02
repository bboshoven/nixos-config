{ ... }: {

  networking.firewall.allowedTCPPorts = [ 80 443 ];
  networking.firewall.allowedUDPPorts = [ 80 443 ];

  fileSystems."/mnt/nixflix" = {
    device = "10.4.0.201:/volume1/nixflix";
    fsType = "nfs";
    options = [ "defaults" "nofail" ];
  };

  boot.kernel.sysctl = {
    "net.ipv6.conf.enp0s13f0u4u1.accept_ra" = 2;
    "net.ipv6.conf.enp0s13f0u4u1.accept_ra_rt_info_max_plen" = 64;
  };
  
  networking = {
    interfaces.enp0s13f0u4u1 = {
      ipv6.addresses = [{
        address = "fd85:7d8c:f860:50::100";
        prefixLength = 64;
      }];
      ipv4.addresses = [{
        address = "10.4.0.100";
        prefixLength = 16;
      }];
    };
    defaultGateway = {
      address = "10.4.0.1";
      interface = "enp0s13f0u4u1";
    };
    defaultGateway6 = {
      address = "fe80::1e0b:8bff:fe16:993d";
      interface = "enp0s13f0u4u1";
    };
  };

}
