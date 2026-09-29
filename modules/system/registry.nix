{ config, pkgs, ... }: {
  services.dockerRegistry = {
    enable = true;
    listenAddress = "0.0.0.0";
    port = 23369;

    storagePath = "/var/lib/docker-registry";

    extraConfig = {
      storage = {
        delete = {
          enabled = true;
        };
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ 23369 ];

  security.acme = {
    acceptTerms = true;
    certs = {
      "registry.kp.boshoven.dev".email = "boy@boshoven.dev";
    };
  };

  services.nginx = {
    enable = true;
    virtualHosts."registry.kp.boshoven.dev" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:23369";
        proxyWebsockets = true;
        recommendedProxySettings = true;

        basicAuthFile = "/var/lib/nginx/.htpasswd";

        extraConfig = ''
          client_max_body_size 0;

          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;

          proxy_buffering off;
        '';
      };
    };
  };
}
