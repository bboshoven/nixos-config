{ pkgs, ... }: {
  fonts.packages = with pkgs; [
    corefonts
    jetbrains-mono
    nerd-font-patcher
    vista-fonts
  ];
}

