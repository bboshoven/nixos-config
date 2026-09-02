{ ... }: {
  home.stateVersion = "23.05";

  imports = [
    ../../modules/home/workstation/default.nix
  ];
}
