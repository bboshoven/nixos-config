{ ... }: {

  networking.firewall.allowedTCPPorts = [ 80 443 ];
  networking.firewall.allowedUDPPorts = [ 80 443 ];
  
  networking = {
    interfaces.enp0s13f0u4u1 = {
      ipv6.addresses = [{
        address = "fd00::100";
        prefixLength = 64;
      }];
      ipv4.addresses = [{
        address = "10.0.0.100";
        prefixLength = 16;
      }];
    };
    defaultGateway = {
      address = "10.0.0.1";
      interface = "enp0s13f0u4u1";
    };
    defaultGateway6 = {
      address = "fe80::1";
      interface = "enp0s13f0u4u1";
    };
  };

}
