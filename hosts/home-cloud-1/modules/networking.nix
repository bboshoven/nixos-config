{ ... }: {

  # Network (Hetzner uses static IP assignments, and we don't use DHCP here)
  networking.useDHCP = false;
  networking.interfaces."enp41s0".ipv4.addresses = [
    {
      address = "116.202.78.9";
      # Hetzner requires /32, see:
      #     https://docs.hetzner.com/robot/dedicated-server/network/net-config-debian-ubuntu/#ipv4.
      # NixOS automatically sets up a route to the gateway
      # (but only because we set "networking.defaultGateway.interface" below), see
      #     https://github.com/NixOS/nixops/pull/1032#issuecomment-2763497444
      prefixLength = 32;
    }
  ];
  networking.interfaces."enp41s0".ipv6.addresses = [
    {
      address = "2a01:4f8:a0:8323::1";
      prefixLength = 64;
    }
  ];
  networking.defaultGateway = {
    address = "116.202.78.1";
    # Interface must be given for Hetzner networking to work, see comment above.
    interface = "enp41s0";
  };
  networking.defaultGateway6 = { address = "fe80::1"; interface = "enp41s0"; };
  networking.nameservers = [
    "1.1.1.1"
    "2606:4700:4700::1111"
    "2606:4700:4700::1001"
  ];

}
