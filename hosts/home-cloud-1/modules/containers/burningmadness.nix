{ pkgs, ... }: {
  virtualisation.oci-containers = {
    backend = "podman";
    containers.burningmadness = {
      image = "registry.kp.boshoven.dev/stuffsels/burningmadness:0.9.11";
      ports = [
        "13355:3000"
      ];
      environment = {
        COREPACK_HOME = "/tmp/corepack";
        DATABASE_URL = "postgresql://postgres@localhost/burningmadness?host=/run/postgresql";
        PNPM_HOME = "/tmp/.pnpm-home";
        pnpm_config_store_dir = "/tmp/.pnpm-store";
      };
      volumes = [
        "/run/postgresql:/run/postgresql"
        "/var/bm/media:/app/media"
      ];
    };
  };

#  security.acme = {
#    acceptTerms = true;
#    certs = {
#      "bm.c1.boshoven.dev".email = "info@stuffsels.com";
#      "burningmadness.com".email = "info@stuffsels.com";
#      "www.burningmadness.com".email = "info@stuffsels.com";
#    };
#  };

#  services.nginx = {
#    enable = true;
#    virtualHosts."bm.c1.boshoven.dev" = {
#      enableACME = true;
#      forceSSL = true;
#      locations."/" = {
#        proxyPass = "http://127.0.0.1:13355";
#        proxyWebsockets = true;
#        recommendedProxySettings = true;
#        extraConfig = ''
#          proxy_buffering off;
#        '';
#      };
#    };
##    virtualHosts."burningmadness.com" = {
##      globalRedirect = "www.burningmadness.com";
##    };
#    virtualHosts."burningmadness.com" = {
#      enableACME = true;
#      forceSSL = true;
#      globalRedirect = "www.burningmadness.com";
#    };
#    virtualHosts."www.burningmadness.com" = {
#      enableACME = true;
#      forceSSL = true;
#      locations."/" = {
#        proxyPass = "http://127.0.0.1:13355";
#        proxyWebsockets = true;
#        recommendedProxySettings = true;
#        extraConfig = ''
#          proxy_buffering off;
#        '';
#      };
#    };
#  };
}
