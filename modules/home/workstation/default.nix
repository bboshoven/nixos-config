{ pkgs, ... }: {
  imports = [
    ./programs
  ];

  home.username = "boy";
  home.homeDirectory = "/home/boy";

  programs.home-manager.enable = true;

  home.stateVersion = "23.05";
}

