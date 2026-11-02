{ config, pkgs, ... }:

let
  base = "/var/lib/nginx/pangolin-certs";

  remoteHost = "c1.boshoven.dev";
  remoteUser = "certsync";

  privateKey = "/var/lib/pangolin-cert-sync/id_ed25519";

  remotePath = "/var/lib/pangolin/cert-export/current/";

  nginxGroup = config.services.nginx.group;

  syncScript = pkgs.writeShellApplication {
    name = "sync-pangolin-certs";

    runtimeInputs = with pkgs; [
      coreutils
      findutils
      diffutils
      openssh
      rsync
      openssl
      systemd
    ];

    text = ''
      set -euo pipefail
      umask 077

      BASE=${base}

      install -d -m 750 -o root -g ${nginxGroup} "$BASE"
      install -d -m 750 -o root -g ${nginxGroup} "$BASE/releases"

      STAGE=$(mktemp -d "$BASE/releases/.stage.XXXXXXXX")

      cleanup() {
        if [ -d "$STAGE" ]; then
          rm -rf -- "$STAGE"
        fi
      }
      trap cleanup EXIT

      echo "Downloading certificates from ${remoteHost}"

      rsync -rtL \
        -e "ssh \
          -i ${privateKey} \
          -o BatchMode=yes \
          -o IdentitiesOnly=yes \
          -o StrictHostKeyChecking=yes" \
        "${remoteUser}@${remoteHost}:${remotePath}" \
        "$STAGE/"

      # Do not accept an empty certificate export.
      test -n "$(find "$STAGE" -mindepth 1 -print -quit)"

      echo "Validating certificates"

      count=0

      for dir in "$STAGE"/*; do
        [ -d "$dir" ] || {
          echo "Unexpected file in certificate export" >&2
          exit 1
        }

        domain=$(basename "$dir")

        [[ "$domain" =~ ^[a-zA-Z0-9-]+(\.[a-zA-Z0-9-]+)+$ ]] || {
          echo "Invalid hostname: $domain" >&2
          exit 1
        }

        cert="$dir/fullchain.pem"
        key="$dir/privkey.pem"

        test -s "$cert"
        test -s "$key"

        # Validate certificate and hostname.
        openssl x509 -in "$cert" -noout \
          -checkhost "$domain"

        # Must remain valid for at least 24 hours.
        openssl x509 -in "$cert" -noout \
          -checkend 86400

        # Validate the private key.
        openssl pkey -in "$key" -noout

        # Ensure public keys match.
        cert_hash=$(
          openssl x509 -in "$cert" -pubkey -noout |
            openssl pkey -pubin -outform DER |
            openssl dgst -sha256
        )

        key_hash=$(
          openssl pkey -in "$key" -pubout -outform DER |
            openssl dgst -sha256
        )

        if [ "$cert_hash" != "$key_hash" ]; then
          echo "Certificate/key mismatch: $domain" >&2
          exit 1
        fi

        # Allow nginx to traverse directories and read keys.
        chown root:${nginxGroup} "$dir" "$cert" "$key"

        chmod 750 "$dir"
        chmod 640 "$cert"
        chmod 640 "$key"

        count=$((count + 1))
        echo "Validated: $domain"
      done

      # Make release directory accessible to nginx.
      chown root:${nginxGroup} "$STAGE"
      chmod 750 "$STAGE"

      echo "Validated $count certificates"

      # Migrate permissions from earlier importer versions.
      if [ -d "$BASE/current" ]; then
        chgrp -R ${nginxGroup} "$BASE/releases"

        find "$BASE/releases" -type d \
          -exec chmod 750 {} +

        find "$BASE/releases" -type f \
          -name '*.pem' -exec chmod 640 {} +
      fi

      # Skip activation if contents are identical.
      if [ -d "$BASE/current" ] &&
         diff -qr "$BASE/current" "$STAGE" >/dev/null; then
        echo "No certificate changes"
        exit 0
      fi

      # Remember previous release.
      OLD=""
      if [ -L "$BASE/current" ]; then
        OLD=$(readlink "$BASE/current")
      fi

      # Publish new release.
      release="$BASE/releases/$(date +%s)-$$"

      mv "$STAGE" "$release"
      ln -s "$release" "$BASE/.current-new"
      mv -Tf "$BASE/.current-new" "$BASE/current"

      rollback() {
        echo "Rolling back certificate update" >&2

        if [ -n "$OLD" ]; then
          ln -s "$OLD" "$BASE/.current-rollback"
          mv -Tf "$BASE/.current-rollback" "$BASE/current"
        else
          rm -f "$BASE/current"
        fi
      }

      # NixOS nginx validates its configuration when reloading.
      if systemctl is-active --quiet nginx.service; then
        echo "Reloading nginx"

        if ! systemctl reload nginx.service; then
          rollback
          exit 1
        fi
      else
        echo "nginx is not running; certificates installed"
      fi

      echo "Certificate sync completed successfully"
    '';
  };

in
{
  # Ensure nginx can traverse its parent certificate directory.
  # Existing contents are not removed.
  systemd.tmpfiles.rules = [
    "d /var/lib/nginx 0750 root ${nginxGroup} - -"
  ];

  systemd.services.pangolin-cert-import = {
    description = "Import TLS certificates from Pangolin";

    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];

    serviceConfig = {
      Type = "oneshot";
      User = "root";
      Group = "root";
      UMask = "0077";

      ExecStart =
        "${syncScript}/bin/sync-pangolin-certs";
    };
  };

  systemd.timers.pangolin-cert-import = {
    wantedBy = [ "timers.target" ];

    timerConfig = {
      OnBootSec = "2min";
      OnUnitActiveSec = "1h";
      Persistent = true;
      Unit = "pangolin-cert-import.service";
    };
  };
}

