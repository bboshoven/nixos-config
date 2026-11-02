{ config, pkgs, ... }: {

  sops.defaultSopsFile = ../../secrets/secrets.yaml;
  sops.age.keyFile = "/home/boy/.config/sops/age/keys.txt"; # Path to private key on target host

  # Define individual secrets
#  sops.secrets.my_secret_password = {
    # Optional: change owner, permissions, or custom path if needed
    # mode = "0400";
    # owner = "username";
#  };
}
