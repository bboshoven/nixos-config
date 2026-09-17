{ pkgs, ... }: {
  users.users.boy = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    packages = with pkgs; [];
    openssh.authorizedKeys.keys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMy3/7d3Vx4pF/+yrfHJFtrIL+tmI7wreyjEqh05ICl6 boy@boy-desktop"];
  };
}