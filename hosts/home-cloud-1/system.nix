{ ... }: {
  imports = [
    ./modules/networking.nix

    ../../modules/system/user.nix
    ../../modules/system/locale.nix
    ../../modules/system/time.nix
    ../../modules/system/keyboard.nix
    ../../modules/system/network-manager.nix

    ../../modules/system/packages.nix
  ];
}
