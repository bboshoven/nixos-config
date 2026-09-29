{ ... }: {
  networking.networkmanager.enable = true;
  networking.networkmanager.dns = "none";
  users.users.boy.extraGroups = [ "networkmanager" ];
}
