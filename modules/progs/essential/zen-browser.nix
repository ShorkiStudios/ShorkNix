{
  home = { inputs, pkgs, ... }: {
    imports = [
      inputs.zen-browser.homeModules.twilight
    ];

    programs.zen-browser = {
      enable = true;

      policies = {
        DisableAppUpdate = false;
        DisableTelemetry = true;
      };

      nativeMessagingHosts = [
        pkgs.firefoxpwa
      ];
    };

    home.sessionVariables.MOZ_LEGACY_PROFILES = "1";
  };
}
