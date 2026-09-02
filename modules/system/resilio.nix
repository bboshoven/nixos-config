{ ... }: {
  services.resilio.enable = true;
  services.resilio.enableWebUI = true;
  users.users.boy.extraGroups = [ "rslsync" ];
}