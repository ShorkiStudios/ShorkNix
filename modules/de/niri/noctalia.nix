{
  os = { inputs, pkgs, ... }: {
    environment.systemPackages = [
      inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
      pkgs.jq
    ];

    services.upower.enable = true;
    services.power-profiles-daemon.enable = true;
  };
}
