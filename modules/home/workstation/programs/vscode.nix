{ pkgs, ... }: {
  programs.vscode = {
    enable = true;
    profiles.default.userSettings = {
      "telemetry.telemetryLevel" = "off";
      "dotnet.autoDetect" = "off";
      "svelte.enable-ts-plugin" = true;
      "editor.formatOnSave" = true;
      "[typescript]" = {
        "editor.defaultFormatter" = "esbenp.prettier-vscode";
      };
    };
    package = pkgs.vscode.fhs;
  };
}
