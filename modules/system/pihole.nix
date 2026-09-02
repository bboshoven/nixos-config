{ ... }: {
  services.pihole-ftl = {
    enable = true;
    settings = {
      dns.upstreams = [
        "86.54.11.100"
        "2a13:1001::86:54:11:100"
        "1.1.1.1"
        "2606:4700:4700::1111"
      ];
      dns.hosts = [ "10.0.0.100 pi.hole" "10.0.0.100 immich.kp.boshoven.dev" ];
#      dns.specialDomains.iCloudPrivateRelay = false;
    };
    settings = {
      dns = {
        rateLimit = {
          count = 5000;
        };
      };
    };
#    lists = [
#      {
#        url = "https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@latest/adblock/pro.txt";
#        type = "block";
#        enabled = true;
#        description = "Hagezi PRO";
#      }
#      {
#        url = "https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists@latest/adblock/nsfw.txt";
#        type = "block";
#        enabled = true;
#        description = "Hagezi NSFW";
#      }
#    ];
  };

  services.pihole-web = {
    enable = true;
    ports = [ 50001 ];
  };

  networking.firewall.allowedTCPPorts = [ 53 50001 ];
  networking.firewall.allowedUDPPorts = [ 53 ];
}
