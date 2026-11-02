{ config, ... }: {
  # The secret is consumed as a systemd EnvironmentFile, so its contents must
  # be a dotenv-style line, e.g.:
  #
  #   ADMIN_TOKEN=<generated token>
  #
  # Add it to secrets/secrets.yaml with `sops secrets/secrets.yaml`.
  sops.secrets."vaultwarden/env" = {};

  services.vaultwarden = {
    enable = true;

    # Public URL used by clients and for WebAuthn. The service is reached
    # through the Pangolin/Newt tunnel on this host.
    domain = "vault.boshoven.dev";

    # ADMIN_TOKEN and any future secrets (e.g. SMTP_PASSWORD) come from here,
    # so they never end up in the world-readable Nix store.
    environmentFile = config.sops.secrets."vaultwarden/env".path;

    config = {
      ROCKET_ADDRESS = "127.0.0.1";
      ROCKET_PORT = 8222;

      # No public registration; invite users from the admin UI instead.
      SIGNUPS_ALLOWED = true;
      INVITATIONS_ALLOWED = false;

      # Keep real-time notifications working through the tunnel.
      ENABLE_WEBSOCKET = true;
    };
  };
}
