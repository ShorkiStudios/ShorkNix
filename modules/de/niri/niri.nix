{
  os = { inputs, pkgs, ... }: {
    imports = [
      inputs.niri.nixosModules.niri
    ];

    programs.niri.enable = true;

    environment.sessionVariables = {
      NIXOS_OZONE_WL = "1";
      XDG_CURRENT_DESKTOP = "niri";
      XDG_SESSION_TYPE = "wayland";
    };

    xdg.portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
      ];
    };
  };
}
