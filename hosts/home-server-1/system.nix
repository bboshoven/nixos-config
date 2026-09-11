{ ... }: {
  imports = [
    ./modules/nvidia.nix
    ./modules/networking.nix
    
    ../../modules/system/user.nix
    ../../modules/system/locale.nix
    ../../modules/system/time.nix
    ../../modules/system/keyboard.nix
    ../../modules/system/network-manager.nix

    ../../modules/system/packages.nix
    ../../modules/system/openssh.nix
    ../../modules/system/immich.nix
    ../../modules/system/pihole.nix
    ../../modules/system/mosquitto.nix
    ../../modules/system/containers/home-assistant.nix
  ];
}
