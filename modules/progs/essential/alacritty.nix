{
  os = { ... }: {
    environment.systemPackages = with pkgs; [ alacritty ];
  };
}
