{ pkgs, config, ... }: {
#  services.home-assistant = {
#    enable = true;
#    openFirewall = true;
#    configDir = /var/lib/hass;
#    extraComponents = [
#      "default_config"
#      "met"
#      "esphome"
#      "overkiz"
#    ];
#    #customComponents = with pkgs.home-assistant-custom-components; [
#    #  hacs
#    #];
#    config = {
#      http = {
#        server_host = "127.0.0.1";
#        trusted_proxies = [ "127.0.0.1" ];
#        use_x_forwarded_for = true;
#      };
#      default_config = {};
#    };
#  };

  boot.kernel.sysctl = {
    "net.ipv6.conf.all.forwarding" = 1;
    "net.ipv4.conf.all.forwarding" = 1;
  };

  networking.firewall.allowedTCPPorts = [ 56374 ];

  virtualisation.oci-containers = {
    backend = "podman";
    containers = {
      matter-server = {
        image = "ghcr.io/home-assistant-libs/python-matter-server:8.1.0";
        autoStart = true;
        extraOptions = [
          "--network=host"
          "--security-opt=apparmor:unconfined"
        ];
        volumes = [
          "/var/lib/matter-server:/data"
        ];
      };
      otbr-router = {
        image = "docker.io/bnutzer/otbr-tcp:20260622";
        autoStart = true;
        privileged = true;
        volumes = [
          "/var/lib/otbr:/data"
        ];
        environment = {
          RCP_HOST = "10.0.0.200";
          OTBR_BACKBONE_IF = "enp0s13f0u4u1";
          OTBR_LOG_LEVEL_INT = "7";
          #OTBR_WEB_PORT = "56374";
          #OTBR_WEB_ENABLE = "1";
        };
        extraOptions = [
          "--network=host"
          "--device=/dev/net/tun:/dev/net/tun"
        ];
      };
      homeassistant = {
        # Pulls the official stable image directly from Home Assistant
        image = "ghcr.io/home-assistant/home-assistant:2026.8.3";
        
        environment = {
          TZ = "Europe/Amsterdam"; # Replace with your local timezone
          DBUS_SYSTEM_BUS_ADDRESS = "unix:path=/var/run/dbus/system_bus_socket";
        };

        volumes = [
          # Mounts a mutable folder on your host to persist all configurations and automations
          "/var/lib/homeassistant:/config"
          # Optional: Syncs host time and dbus for hardware/bluetooth detection
          "/etc/localtime:/etc/localtime:ro"
          "/run/dbus:/run/dbus:ro"
          "/var/run/dbus/system_bus_socket:/var/run/dbus/system_bus_socket:ro"
        ];

        extraOptions = [
          # Crucial: Uses the host network namespace so mDNS, Zigbee, and local casting work
          "--network=host"
          "--cap-add=NET_ADMIN"
          "--cap-add=NET_RAW"
          "--ipc=host"
          "--group-add=keep-groups"
          #"--userns=keep-id"
          # Optional: Uncomment if you pass through a USB coordinator (Zigbee/Z-Wave)
          # "--device=/dev/ttyACM0:/dev/ttyACM0"
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
