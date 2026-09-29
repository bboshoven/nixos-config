{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    fosrl-newt
  ];

  systemd.services.newt = {
    description = "Pangolin Newt connector";
    wantedBy = [ "multi-user.target" ];
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];

    serviceConfig = {
      EnvironmentFile = "/etc/newt.env";
      StateDirectory = "newt";
      ExecStart = "${pkgs.fosrl-newt}/bin/newt --config-file /var/lib/newt/config.json --id $NEWT_ID --secret $NEWT_SECRET --endpoint $NEWT_ENDPOINT";
      Restart = "always";
      RestartSec = "5s";
    };
  };
}
