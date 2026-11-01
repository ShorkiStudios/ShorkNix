{
  home =
    { pkgs, lib, ... }:
    {
      home.packages = [ pkgs.btop ];
      wayland.windowManager.hyprland.settings.bind = [
        {
          _args = [
            # barbados 2026-11-01: moved SUPER+SHIFT+M → SUPER+CTRL+T
            # (its Omarchy key); SUPER+SHIFT+M is Spotify now.
            "SUPER + CTRL + T"
            (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"kitty --class btop btop\")")
          ];
        }
      ];
    };
}
