{ pkgs, ... }: {
  virtualisation.oci-containers.containers.nginx-server = {
    image = "docker.io/library/nginx:alpine";
    
    ports = [ "47545:80" ];

    autoStart = true;
  };

  security.acme = {
    acceptTerms = true;
    certs = {
      "test.c1.boshoven.dev".email = "boy@boshoven.dev";
    };
  };

  services.nginx = {
    enable = true;
    virtualHosts."test.c1.boshoven.dev" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:47545";
        proxyWebsockets = true;
        recommendedProxySettings = true;
        extraConfig = ''
          proxy_buffering off;
        '';
      };
    };
  };
}
