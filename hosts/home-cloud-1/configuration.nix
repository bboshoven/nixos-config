{ config, pkgs, ... }: {
  imports = [
    ./hardware-configuration.nix
    ./system.nix
  ];

  # Use GRUB2 as the boot loader.
  # We use BIOS legacy boot (no UEFI).
  boot.loader.systemd-boot.enable = false;
  boot.loader.grub = {
    enable = true;
    efiSupport = false;
    devices = ["/dev/disk/by-id/nvme-SAMSUNG_MZVL2512HCJQ-00B00_S675NF0T330640" "/dev/disk/by-id/nvme-SAMSUNG_MZVL2512HCJQ-00B00_S675NF0T330808"];
    copyKernels = true;
  };
  boot.supportedFilesystems = [ "zfs" ];
  boot.kernelParams = ["boot.shell_on_fail"];

  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "home-cloud-1";

  users.users.root.initialHashedPassword = "";
  users.users.root.openssh.authorizedKeys.keys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMy3/7d3Vx4pF/+yrfHJFtrIL+tmI7wreyjEqh05ICl6 boy@boy-desktop"];

  services.openssh.enable = true;
  services.openssh.settings = {
    PermitRootLogin = "prohibit-password";
  };

  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  system.stateVersion = "25.11"; # Adjust to your current version
}
