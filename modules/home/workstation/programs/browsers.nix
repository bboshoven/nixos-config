{ pkgs, config, ... }: {
  home.packages = with pkgs; [
    google-chrome
  ];

  programs = {
    firefox = {
      enable = true;
      profiles.boy = {};
      configPath = "${config.xdg.configHome}/mozilla/firefox";
    };
  };
}

