{
  home =
    { pkgs, lib, ... }:
    {
      home.packages = [ pkgs.telegram-desktop ];
      # barbados 2026-11-01: SUPER+T bind removed — the Omarchy
      # keybind layer claims SUPER+T for float toggle. Telegram is
      # launcher-only now.
      wayland.windowManager.hyprland.settings.bind = [ ];
    };
}
