{
  os = { systemSettings, ... }: {
    networking.hostName = systemSettings.hostname;
    networking.networkmanager.enable = true;
    networking.networkmanager.wifi.backend = "iwd";
  };
}
