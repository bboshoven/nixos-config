{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    pangolin-cli
  ];

  systemd.services.pangolin-client = {
    description = "Pangolin client";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];

    serviceConfig = {
      EnvironmentFile = "/etc/pangolin-client.env";
      Environment = "HOME=/var/lib/pangolin-client";
      StateDirectory = "pangolin-client";
      ExecStart = "${pkgs.pangolin-cli}/bin/pangolin up client --id $PANGOLIN_ID --secret $PANGOLIN_SECRET --endpoint $PANGOLIN_ENDPOINT --attach";
      Restart = "always";
      RestartSec = "5s";
    };
  };
}
