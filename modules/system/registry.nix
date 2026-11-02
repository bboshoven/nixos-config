{ config, pkgs, ... }: {
  services.dockerRegistry = {
    enable = true;
    listenAddress = "0.0.0.0";
    port = 23369;

    storagePath = "/var/lib/docker-registry";

    extraConfig = {
      log.level = "debug";
      http.relativeurls = true;
      storage = {
        delete = {
          enabled = true;
        };
      };
    };
  };

#  networking.firewall.allowedTCPPorts = [ 23369 ];

#  security.acme = {
#    acceptTerms = true;
#    certs = {
#      "registry.kp.boshoven.dev".email = "boy@boshoven.dev";
#    };
#  };

  services.nginx = {
    enable = true;
    appendHttpConfig = ''
      access_log syslog:server=unix:/dev/log combined;
    '';
    virtualHosts."localhost" = {
#      enableACME = true;
#      forceSSL = true;
      listen = [ { addr = "127.0.0.1"; port = 32269; } ];
      locations."/" = {
        proxyPass = "http://127.0.0.1:23369";
        proxyWebsockets = true;
        recommendedProxySettings = true;

        basicAuthFile = "/var/lib/nginx/.htpasswd";

        extraConfig = ''
          client_max_body_size 0;
          client_body_timeout 900s;

#          proxy_http_version 1.1;
          proxy_request_buffering off;
          proxy_buffering off;

          proxy_read_timeout 900s;
          proxy_send_timeout 900s;
        '';
      };
    };
  };
}
