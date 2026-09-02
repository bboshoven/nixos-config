{ pkgs, ... }: {
  programs.vscode = {
    enable = true;
    profiles.default.userSettings = {
      "telemetry.telemetryLevel" = "off";
      "dotnet.autoDetect" = "off";
    };
    package = pkgs.vscode.fhs;
  };
}
