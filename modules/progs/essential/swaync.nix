{
  os = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [ swaynotificationcenter ];
  };
}
