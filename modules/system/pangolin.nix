{ pkgs, ... }: {
  boot.kernelModules = [ "wireguard" ];
  networking.wireguard.enable = true; 
  networking.firewall.checkReversePath = "loose";
  networking.firewall.trustedInterfaces = [ "wg0" ];
  networking.firewall.allowedUDPPorts = [ 51820 ];

  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
  };

#  networking.firewall.extraCommands = ''
#    iptables -t nat -A POSTROUTING -s 10.100.0.0/24 -o enp41s0 -j MASQUERADE
#  '';

#  systemd.services.pangolin = {
#    serviceConfig = {
#      StateDirectory = [ "pangolin" "pangolin/.next" ];
#    };
#  };

  services.pangolin = {
    enable = true;
#    serviceConfig = {
#      StateDirectory = [ "pangolin" "pangolin/.next" ];
#    };
    # this part is technically not needed,
    # but omitting it will allow 
    # ANYONE TO CREATE ACCOUNTS AND 
    # ORGANIZATIONS ON YOUR PANGOLIN INSTANCE
#    settings = {
#      flags = {
#        disable_signup_without_invite = true;
#        disable_user_create_org = true;
#      };
#    };
    baseDomain = "c1.boshoven.dev";
    letsEncryptEmail = "info@stuffsels.com"; # an email you have access to
    openFirewall = true; 
    environmentFile = "/etc/nixos/secrets/pangolin.env";
  };

}
