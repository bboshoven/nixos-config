{ config, ... }: {

  sops.secrets = {
    "sonarr/api_key" = {};
    "sonarr/password" = {};
    "sonarr-anime/api_key" = {};
    "sonarr-anime/password" = {};
    "radarr/api_key" = {};
    "radarr/password" = {};
    "lidarr/api_key" = {};
    "lidarr/password" = {};
    "prowlarr/api_key" = {};
    "prowlarr/password" = {};
    "indexer-api-keys/NzbLife" = {};
    "indexer-api-keys/NzbLife" = {};
    "jellyfin/api_key" = {};
    "jellyfin/boy_password" = {};
    "seerr/api_key" = {};
    "wireguard/conf" = {};
    "sabnzbd/api_key" = {};
    "sabnzbd/nzb_key" = {};
    "sabnzbd/username" = {};
    "sabnzbd/password" = {};
    "usenet/eweka/username" = {};
    "usenet/eweka/password" = {};
    "navidrome/admin_password" = {};
  };

  nixflix = {
    enable = true;
    mediaDir = "/data/nixflix/media";
    downloadsDir = "/data/nixflix/downloads";
    stateDir = "/data/nixflix/.state";

    # Reverse proxy: choose one
    #nginx.enable = true;
    # caddy.enable = true;

    postgres.enable = true;

    sonarr = {
      enable = true;
      config = {
        apiKey = {_secret = config.sops.secrets."sonarr/api_key".path;};
        hostConfig.password = {_secret = config.sops.secrets."sonarr/password".path;};
      };
    };

    sonarr-anime = {
      enable = true;
      config = {
        apiKey = {_secret = config.sops.secrets."sonarr-anime/api_key".path;};
        hostConfig.password = {_secret = config.sops.secrets."sonarr-anime/password".path;};
      };
    };

    radarr = {
      enable = true;
      config = {
        apiKey = {_secret = config.sops.secrets."radarr/api_key".path;};
        hostConfig.password = {_secret = config.sops.secrets."radarr/password".path;};
      };
    };

    lidarr = {
      enable = true;
      config = {
        apiKey = {_secret = config.sops.secrets."lidarr/api_key".path;};
        hostConfig.password = {_secret = config.sops.secrets."lidarr/password".path;};
      };
    };

    prowlarr = {
      enable = true;
      config = {
        apiKey = {_secret = config.sops.secrets."prowlarr/api_key".path;};
        hostConfig.password = {_secret = config.sops.secrets."prowlarr/password".path;};
        indexers = [
          {
            name = "NZB.life";
            schemaName = "NZB.life";
            apiKey._secret = config.sops.secrets."indexer-api-keys/NzbLife".path;
          }
        ];
      };
    };

    usenetClients.sabnzbd = {
      enable = true;

      settings = {
        misc = {
          api_key._secret = config.sops.secrets."sabnzbd/api_key".path;
          nzb_key._secret = config.sops.secrets."sabnzbd/nzb_key".path;
          username._secret = config.sops.secrets."sabnzbd/username".path;
          password._secret = config.sops.secrets."sabnzbd/password".path;
          host_whitelist = "sabnzbd.boshoven.dev";
          inet_exposure = "api+web (auth needed)";
        };

        servers = [
          {
            name = "Eweka";
            host = "sslreader.eweka.nl";
            port = 563;
            username._secret = config.sops.secrets."usenet/eweka/username".path;
            password._secret = config.sops.secrets."usenet/eweka/password".path;
            connections = 20;
            ssl = true;
            priority = 0;
            retention = 3000;
          }
        ];
      };
    };

    seerr = {
      enable = true;
      apiKey._secret = config.sops.secrets."seerr/api_key".path;
    };

    jellyfin = {
      enable = true;
      apiKey._secret = config.sops.secrets."jellyfin/api_key".path;
      system.metadataPath = "/data/nixflix/.state/jellyfin/metadata";
      users.boy = {
        mutable = false;
        policy.isAdministrator = true;
        password = {_secret = config.sops.secrets."jellyfin/boy_password".path;};
      };
    };

    navidrome = {
      enable = true;
      users.admin = {
        userName = "admin";
        isAdmin = true;
        password = {_secret = config.sops.secrets."navidrome/admin_password".path;};
      };
    };
  };
}
