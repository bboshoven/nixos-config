{ ... }: {

  services.sabnzbd = {
    enable = true;
  
    settings = {
      misc = {
        port = 42070;
        host = "0.0.0.0";
      };
    };
  };

}
