{ pkgs, ... }: {
  home.packages = with pkgs; [
    vlc
    gimp3
  ];

  programs = {
    direnv = {
      enable = true;
      enableBashIntegration = true;
      nix-direnv.enable = true;
    };

    bash.enable = true;
  };
}

