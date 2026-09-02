{ ... }: {
  imports = [
    ./modules/nvidia.nix
    ./modules/sound.nix

    ../../modules/system/locale.nix
    ../../modules/system/time.nix
    ../../modules/system/keyboard.nix
    ../../modules/system/fonts.nix
    ../../modules/system/plasma.nix
    ../../modules/system/network-manager.nix

    ../../modules/system/packages.nix
    ../../modules/system/openssh.nix
    ../../modules/system/resilio.nix
    ../../modules/system/steam.nix
  ];
}
