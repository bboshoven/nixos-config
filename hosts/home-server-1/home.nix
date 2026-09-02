{ ... }: {
  home.stateVersion = "25.11";

  imports = [
    ../../modules/home/server/default.nix
  ];
}
