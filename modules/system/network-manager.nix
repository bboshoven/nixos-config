{ ... }: {
  networking.networkmanager.enable = true;
  users.users.boy.extraGroups = [ "networkmanager" ];
}
