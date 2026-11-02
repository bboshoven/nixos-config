{ pkgs, ... }: {
  virtualisation.oci-containers = {
    backend = "podman";
    containers.okane = {
      image = "registry.c1.boshoven.dev/stuffsels/okane-backend:0.5.1";
      ports = [
        "13356:8080"
      ];
      environment = {
        ConnectionStrings__MoneySql = "Host=/run/postgresql;Database=okane;Username=postgres;";
        JwtSettings__SecretKey = "UKE2BcsA2c6j7dYsWWXf1Qfm8PCkySyW6mpkbSafFkhcFZPD6HDyBdtDzGrSNhGC";
        JwtSettings__Issuer = "OkaneBackend";
        Hosting__Cors__0 = "https://okane.boshoven.dev";
      };
      volumes = [
        "/run/postgresql:/run/postgresql"
      ];
    };
    containers.okane-frontend = {
      image = "registry.c1.boshoven.dev/stuffsels/okane-frontend:0.5.4";
      ports = [
        "13357:8080"
      ];
      environment = {
      };
      volumes = [
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
