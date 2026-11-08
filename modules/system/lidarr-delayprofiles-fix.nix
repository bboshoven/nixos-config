{ config, lib, pkgs, ... }:
let
  inherit (lib)
    concatMapStringsSep
    escapeShellArg
    isAttrs
    mkForce
    mkIf
    optionalString
    sort
    ;

  cfg = config.nixflix.lidarr;

  # Keep in sync with nixflix's modules/arr-common/delayProfiles.nix default.
  defaultDelayProfile = {
    enableUsenet = true;
    enableTorrent = true;
    preferredProtocol = "usenet";
    usenetDelay = 0;
    torrentDelay = 0;
    bypassIfHighestQuality = true;
    bypassIfAboveCustomFormatScore = false;
    minimumCustomFormatScore = 0;
    order = 2147483647;
    tags = [ ];
    id = 1;
  };

  configuredIds = map (profile: profile.id) cfg.config.delayProfiles;
  mergedProfiles =
    if builtins.elem 1 configuredIds then
      cfg.config.delayProfiles
    else
      [ defaultDelayProfile ] ++ cfg.config.delayProfiles;
  sortedProfiles = sort (a: b: a.id < b.id) mergedProfiles;

  # Lidarr 3.1.6 replaced the flat delay-profile fields with a list of
  # per-protocol items. This mirrors migration 043_flexible_delay_profiles.cs.
  toApiProfile =
    profile:
    let
      usenet = {
        name = "Usenet";
        protocol = "UsenetDownloadProtocol";
        allowed = profile.enableUsenet;
        delay = profile.usenetDelay;
      };
      torrent = {
        name = "Torrent";
        protocol = "TorrentDownloadProtocol";
        allowed = profile.enableTorrent;
        delay = profile.torrentDelay;
      };
    in
    {
      inherit (profile)
        id
        bypassIfHighestQuality
        bypassIfAboveCustomFormatScore
        minimumCustomFormatScore
        order
        tags
        ;
      name = if profile.id == 1 then "Default" else "Delay Profile ${toString profile.id}";
      items = if profile.preferredProtocol == "usenet" then [ usenet torrent ] else [ torrent usenet ];
    };

  apiKey = cfg.config.apiKey;
  isSecretRef = value: isAttrs value && value ? _secret;
  apiKeyArgs =
    if apiKey == null then
      ""
    else if isSecretRef apiKey then
      "--variable apiKey@${escapeShellArg (toString apiKey._secret)} --expand-header ${escapeShellArg "X-Api-Key: {{apiKey:trim}}"} "
    else
      "--header ${escapeShellArg "X-Api-Key: ${toString apiKey}"} ";

  mkCurl =
    {
      url,
      method ? "GET",
      data ? null,
    }:
    let
      methodArg = optionalString (method != "GET") "-X ${method} ";
      contentTypeArg = optionalString (data != null) "--header 'Content-Type: application/json' ";
      dataArg = optionalString (data != null) "--data-binary ${escapeShellArg data} ";
    in
    "${pkgs.curl}/bin/curl -sSf ${methodArg}${apiKeyArgs}${contentTypeArg}${dataArg}\"${url}\"";

  baseUrl = "http://${cfg.config.hostConfig.bindAddress}:${toString cfg.config.hostConfig.port}${cfg.config.hostConfig.urlBase}/api/${cfg.config.apiVersion}";

  script = ''
    set -eu

    BASE_URL="${baseUrl}"

    echo "Fetching existing delay profiles..."
    DELAY_PROFILES=$(${mkCurl { url = "$BASE_URL/delayprofile"; }} 2>/dev/null)

    CONFIGURED_IDS=$(cat <<'EOF'
    ${builtins.toJSON (map (profile: profile.id) sortedProfiles)}
    EOF
    )

    echo "Removing delay profiles not in configuration..."
    echo "$DELAY_PROFILES" | ${pkgs.jq}/bin/jq -r '.[] | @json' | while IFS= read -r profile; do
      PROFILE_ID=$(echo "$profile" | ${pkgs.jq}/bin/jq -r '.id')

      if ! echo "$CONFIGURED_IDS" | ${pkgs.jq}/bin/jq -e --argjson id "$PROFILE_ID" 'index($id)' >/dev/null 2>&1; then
        echo "Deleting delay profile not in config (ID: $PROFILE_ID)"
        ${mkCurl {
          url = "$BASE_URL/delayprofile/$PROFILE_ID";
          method = "DELETE";
        }} >/dev/null 2>&1 || echo "Warning: Failed to delete delay profile $PROFILE_ID (may be in use)"
      fi
    done

    ${concatMapStringsSep "\n" (
      profile:
      let
        profileJson = builtins.toJSON (toApiProfile profile);
        profileId = toString profile.id;
      in
      ''
        echo "Processing delay profile (ID: ${profileId})..."

        EXISTING_PROFILE=$(echo "$DELAY_PROFILES" | ${pkgs.jq}/bin/jq -r '.[] | select(.id == ${profileId}) | @json' || echo "")

        if [ -n "$EXISTING_PROFILE" ]; then
          echo "Delay profile ${profileId} already exists, updating..."
          ${mkCurl {
            url = "$BASE_URL/delayprofile/${profileId}";
            method = "PUT";
            data = profileJson;
          }} > /dev/null
          echo "Delay profile ${profileId} updated"
        else
          echo "Delay profile ${profileId} does not exist, creating..."
          ${mkCurl {
            url = "$BASE_URL/delayprofile";
            method = "POST";
            data = profileJson;
          }} > /dev/null
          echo "Delay profile ${profileId} created"
        fi
      ''
    ) sortedProfiles}

    echo "Lidarr delay profiles configuration complete"
  '';
in
{
  config = mkIf (config.nixflix.enable && cfg.enable && cfg.config.apiKey != null) {
    # nixflix (as of 8402435) still sends the pre-3.1.6 delay-profile shape,
    # which Lidarr 3.1.6 rejects with HTTP 400. Replace just the generated
    # script until nixflix supports the new API.
    systemd.services.lidarr-delayprofiles.script = mkForce script;
  };
}
