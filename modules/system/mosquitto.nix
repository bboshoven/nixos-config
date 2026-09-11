{ ... }: {
  networking.firewall.allowedTCPPorts = [ 1883 ];
  networking.firewall.allowedUDPPorts = [ 1883 ];

  services.mosquitto = {
    enable = true;
    settings = {
      listener = [{
        port = 1883;
        address = "0.0.0.0";
        allow_anonymous = true;
      }];
    };
  };
}