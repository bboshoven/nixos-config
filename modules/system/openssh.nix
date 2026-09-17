{ ... }: {
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = true; # Set to false for SSH keys
    };
  };
}

