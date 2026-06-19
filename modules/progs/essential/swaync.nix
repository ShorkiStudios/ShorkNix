{
  os = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [ swaync ];
  };
}
