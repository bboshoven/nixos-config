{ pkgs, config, ... }: {

  environment.systemPackages = with pkgs; [
    socat
  ];

  boot.kernel.sysctl = {
    "net.ipv6.conf.all.accept_ra" = 2;
    "net.ipv6.conf.default.accept_ra" = 2;
    "net.ipv6.conf.all.forwarding" = 1;
    "net.ipv6.conf.default.forwarding" = 1;
  };

  networking.firewall = {
    enable = true;
    allowedUDPPorts = [ 5353 5540 ];
    allowedTCPPorts = [ 5540 5580 ];
  };

  services.matterjs-server = {
    enable = true;
    port = 5580;
    package = pkgs.matterjs-server;
    extraArgs = [
      "--primary-interface=enp0s13f0u4u1"
      "--vendorid=4939"
    ];
    bluetoothSupport = false;
  };

  virtualisation.oci-containers = {
    backend = "podman";
    containers = {
      homeassistant = {
        image = "ghcr.io/home-assistant/home-assistant:2026.8.3";

        environment = {
          TZ = "Europe/Amsterdam"; # Replace with your local timezone
          DBUS_SYSTEM_BUS_ADDRESS = "unix:path=/var/run/dbus/system_bus_socket";
        };

        volumes = [
          "/var/lib/homeassistant:/config"
          "/etc/localtime:/etc/localtime:ro"
          "/run/dbus:/run/dbus:ro"
          "/var/run/dbus/system_bus_socket:/var/run/dbus/system_bus_socket:ro"
        ];

        extraOptions = [
          "--network=host"
          "--cap-add=NET_ADMIN"
          "--cap-add=NET_RAW"
          "--ipc=host"
          "--group-add=keep-groups"
        ];
      };
    };
  };

  security.acme = {
    acceptTerms = true;
    certs = {
      "ha.kp.boshoven.dev".email = "boy@boshoven.dev";
    };
  };

  services.nginx = {
    enable = true;
    virtualHosts."ha.kp.boshoven.dev" = {
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://127.0.0.1:8123";
        proxyWebsockets = true;
        recommendedProxySettings = true;
        extraConfig = ''
          proxy_buffering off;
        '';
      };
    };
  };

}
