{
  os = { ... }: {
    environment.systemPackages = with pkgs; [ thunar ];
    services.gvfs.enable = true;
  };
}
