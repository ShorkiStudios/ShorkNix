{
  home =
    { pkgs, lib, ... }:
    {
      home.packages = [ pkgs.signal-desktop ];
      wayland.windowManager.hyprland.settings.bind = [
        {
          _args = [
            # barbados 2026-11-01: was "SUPER + F" launching
            # element-desktop (upstream copy-paste bug — this module
            # installs Signal). Omarchy keybind layer: Signal lives
            # on SUPER+SHIFT+G; SUPER+F is fullscreen.
            "SUPER + SHIFT + G"
            (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"signal-desktop\")")
          ];
        }
      ];
    };
}
