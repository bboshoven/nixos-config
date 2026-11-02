{ ... }: {

  nixarr = {
    enable = true;
    # These two values are also the default, but you can set them to whatever
    # else you want
    # WARNING: Do _not_ set them to `/home/user/whatever`, it will not work!
    mediaDir = "/data/media";
    stateDir = "/data/media/.state/nixarr";

    jellyfin = {
      enable = true;
    };
    
    sabnzbd = {
      enable = true;
      whitelistHostnames = [ "boshoven.dev" ];
      guiPort = 6336;
    };

    # It is possible for this module to run the *Arrs through a VPN, but it
    # is generally not recommended, as it can cause rate-limiting issues.
    bazarr.enable = true;
    lidarr.enable = true;
    prowlarr.enable = true;
    radarr.enable = true;
    shelfmark.enable = true;
    sonarr.enable = true;
    seerr.enable = true;
  };

}
