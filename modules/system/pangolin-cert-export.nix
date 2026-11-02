{ pkgs, ... }:

let
  exportScript = pkgs.writeShellApplication {
    name = "export-pangolin-certs";

    runtimeInputs = with pkgs; [
      coreutils
      jq
      openssl
      findutils
    ];

    text = ''
      set -euo pipefail
      umask 077

      ACME=/var/lib/pangolin/config/letsencrypt/acme.json
      BASE=/var/lib/pangolin/cert-export

      install -d -m 750 -o root -g certsync "$BASE"
      install -d -m 750 -o root -g certsync "$BASE/releases"

      STAGE=$(mktemp -d "$BASE/releases/.stage.XXXXXXXX")

      trap 'rm -rf "$STAGE"' EXIT

      jq -c '
        .[] | .Certificates[] |
        {
          domains: ([.domain.main] + (.domain.sans // [])),
          cert: .certificate,
          key: .key
        }
      ' "$ACME" | while IFS= read -r entry; do

        cert=$(jq -r '.cert' <<< "$entry")
        key=$(jq -r '.key' <<< "$entry")

        while IFS= read -r domain; do
          # Skip wildcard certificates.
          [[ "$domain" != \*.* ]] || continue

          # Validate hostname before using it as a path.
          [[ "$domain" =~ ^[a-zA-Z0-9-]+(\.[a-zA-Z0-9-]+)+$ ]] || {
            echo "Invalid domain: $domain" >&2
            exit 1
          }

          dir="$STAGE/$domain"
          mkdir -m 700 "$dir"

          printf '%s' "$cert" |
            base64 -d > "$dir/fullchain.pem"

          printf '%s' "$key" |
            base64 -d > "$dir/privkey.pem"

          # Verify certificate and private key match.
          cert_hash=$(
            openssl x509 -in "$dir/fullchain.pem" -pubkey -noout |
              openssl pkey -pubin -outform DER |
              openssl dgst -sha256
          )

          key_hash=$(
            openssl pkey -in "$dir/privkey.pem" -pubout -outform DER |
              openssl dgst -sha256
          )

          test "$cert_hash" = "$key_hash"

          chmod 640 "$dir/"*.pem

          echo "Exported: $domain"
        done < <(jq -r '.domains[]' <<< "$entry")
      done

      # Prevent accidentally publishing an empty export.
      test -n "$(find "$STAGE" -mindepth 1 -print -quit)"

      chown -R root:certsync "$STAGE"

      find "$STAGE" -type d -exec chmod 750 {} +

      release="$BASE/releases/$(date +%s)-$$"
      mv "$STAGE" "$release"

      ln -s "$release" "$BASE/.current-new"
      mv -Tf "$BASE/.current-new" "$BASE/current"

      echo "Certificate export completed"
    '';
  };
in
{
  users.groups.certsync = {};

  programs.ssh.knownHosts.pangolin = {
    hostNames = [ "c1.boshoven.dev" ];
    publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIotVSGn90o6+w5Ve8bX30EXSc92b9XIQoq5X2du6deq root@home-server-1";
  };

  users.users.certsync = {
    isSystemUser = true;
    group = "certsync";

    home = "/var/lib/certsync";
    createHome = true;

    shell = pkgs.bashInteractive;

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIotVSGn90o6+w5Ve8bX30EXSc92b9XIQoq5X2du6deq root@home-server-1"
    ];
  };

  systemd.services.pangolin-cert-export = {
    path = [ pkgs.acl ];
    description = "Export Pangolin TLS certificates";

    serviceConfig = {
      Type = "oneshot";
      ExecStartPre = "${pkgs.acl}/bin/setfacl -m g:certsync:--x /var/lib/pangolin";
      ExecStart = "${exportScript}/bin/export-pangolin-certs";
      UMask = "0077";
    };
  };

  systemd.timers.pangolin-cert-export = {
    wantedBy = [ "timers.target" ];

    timerConfig = {
      OnBootSec = "1min";
      OnUnitActiveSec = "1h";
      Persistent = true;
    };
  };
}

