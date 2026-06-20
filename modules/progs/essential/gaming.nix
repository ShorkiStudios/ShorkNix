{
  os = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      steam
      steam-run
      discord
      gamemode
    ];

    programs.gamemode.enable = true;

    hardware.steam-hardware.enable = true;
  };
}
