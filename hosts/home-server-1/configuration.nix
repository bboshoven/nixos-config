{ config, pkgs, ... }: {
  imports = [
    ./hardware-configuration.nix
    ./system.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "home-server-1";

  hardware.bluetooth.enable = true;

  services.logind.settings.Login = {
    HandleLidSwitch = "ignore";
    HandleLidSwitchExternalPower = "ignore";
    HandleLidSwitchDocked = "ignore";
  };

  boot.kernelParams = [ "consoleblank=300" ];

  programs.ssh.knownHosts.pangolin = {
    hostNames = [ "c1.boshoven.dev" ];

    publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBKB1Vtiv43g9aS0+RmGi7SUfIhnZnulfCSmsgpqvVLQ root@boy-cloud-1";
  };

  nixpkgs.config.allowUnfree = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  system.stateVersion = "25.11"; # Adjust to your current version
}
