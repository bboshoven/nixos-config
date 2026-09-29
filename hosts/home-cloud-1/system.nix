{ ... }: {
  imports = [
    ./modules/networking.nix
    ./modules/containers/burningmadness.nix

    ../../modules/system/user.nix
    ../../modules/system/locale.nix
    ../../modules/system/time.nix
    ../../modules/system/keyboard.nix
#    ../../modules/system/network-manager.nix

    ../../modules/system/packages.nix
    ../../modules/system/pangolin.nix
#    ../../modules/system/pangolin-cli.nix
    ../../modules/system/openssh.nix
    ../../modules/system/postgresql.nix
    ../../modules/system/podman.nix
  ];
}
