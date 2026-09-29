{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    wget
    git
    curl
    iotop
    bind
    traceroute
  ];
}
