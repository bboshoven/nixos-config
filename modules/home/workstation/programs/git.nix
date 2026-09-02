{ ... }: {
  programs.git = {
    enable = true;

    settings.user.name = "bboshoven";
    settings.user.email = "boy@boshoven.dev";
  };
}
