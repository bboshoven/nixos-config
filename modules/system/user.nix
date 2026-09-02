{ pkgs, ... }: {
  users.users.boy = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    packages = with pkgs; [];
  };
}