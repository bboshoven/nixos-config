{ pkgs, ... }: {
  home.packages = with pkgs; [
    vlc
    gimp3
    devenv
    bottles
    pdfarranger
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

