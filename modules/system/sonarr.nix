{ ... }: {

  users.groups.media = {
    gid = 1800;
  };

  services.sonarr = {
    enable = true;
    group = "media";
  };

}
