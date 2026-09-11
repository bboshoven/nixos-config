{ pkgs, ... }: {
  home.packages = with pkgs; [
    vlc
    gimp3
    devenv
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

