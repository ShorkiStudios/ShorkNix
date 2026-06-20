{
  os = { pkgs, ... }: {
    programs.niri.enable = true;

    environment.sessionVariables = {
      NIXOS_OZONE_WL = "1";
      XDG_CURRENT_DESKTOP = "niri";
      XDG_SESSION_TYPE = "wayland";
      XCURSOR_THEME = "Imouto";
      XCURSOR_SIZE = "48";
      QT_ICON_THEME = "Papirus-Dark";
    };

    xdg.portal = {
      enable = true;
      wlr.enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
      ];
    };

    services.gnome.gnome-keyring.enable = true;

    environment.systemPackages = with pkgs; [
      xwayland-satellite
      wl-clipboard
      grim
      slurp
      swappy
      brightnessctl
      playerctl
      pavucontrol
      pamixer
      networkmanagerapplet
      papirus-icon-theme
      noto-fonts
      noto-fonts-color-emoji
    ];
  };
}
