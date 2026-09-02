{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    libreoffice-qt
    hunspell
    hunspellDicts.nl_NL
  ];
}