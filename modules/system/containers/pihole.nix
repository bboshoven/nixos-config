{ config, pkgs, ... }: {

  virtualisation.oci-containers = {
    backend = "podman";
    containers.pihole = {
      image = "pihole/pihole:latest";
      ports = [
        "53:53/tcp"
        "53:53/udp"
        "8080:80/tcp" # Web UI accessible at port 8080
      ];
      environment = {
        TZ = "Europe/Amsterdam";
        FTLCONF_webserver_api_password = "3ejy8ccKvaQW";
      };
      volumes = [
        "/var/lib/pihole/:/etc/pihole/"
        "/var/lib/dnsmasq.d/:/etc/dnsmasq.d/"
      ];
    };
  };

  networking.nameservers = [ 
    "127.0.0.1"
    "86.54.11.100"
    "86.54.11.200"
    "1.1.1.1"
  ];

  # Open firewall ports for Pi-hole
  networking.firewall.allowedTCPPorts = [ 53 8080 ];
  networking.firewall.allowedUDPPorts = [ 53 ];
}
