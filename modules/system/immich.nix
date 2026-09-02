{ config, pkgs, ... }: {

  services.immich = {
    enable = true;
    port = 2283; # Default port
    host = "0.0.0.0";
    mediaLocation = "/mnt/photos/immich";
    
    # Optional: Open the firewall port
    # networking.firewall.allowedTCPPorts = [ 2283 ];
  };

  # High-performance machine learning (Recommended)
  # This enables hardware acceleration for video/image processing
  services.immich.machine-learning = {
    enable = true;
  };
  
  users.users.immich.extraGroups = [ "video" "render" ];
  users.users.boy.extraGroups = [ "immich" ];

  security.acme = {
    acceptTerms = true;
    certs = {
      "immich.kp.boshoven.dev".email = "boy@boshoven.dev";
    };
  };

  services.nginx = {
    enable = true;
    virtualHosts."immich.kp.boshoven.dev" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:${toString config.services.immich.port}";
        proxyWebsockets = true;
        recommendedProxySettings = true;
        extraConfig = ''
          client_max_body_size 50000M;
          proxy_read_timeout   600s;
          proxy_send_timeout   600s;
          send_timeout         600s;
        '';
      };
    };
  };

}
