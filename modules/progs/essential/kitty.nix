{
  home =
    { lib, style, ... }:
    {
      programs.kitty = {
        enable = true;
        font = {
          name = style.font.name;
          size = style.font.size / 1.2;
        };
        shellIntegration.enableBashIntegration = true;
        enableGitIntegration = true;
        settings = {
          cursor_shape = "beam";
          cursor_shape_unfocused = "unchanged";
          background_opacity = 0.0;
          confirm_os_window_close = 0;
          cursor_trail = 3;
          cursor_trail_decay = "0.1 0.5";
          remember_window_size = false;
          # Pansexual flag palette (barbados, 2026-11-01, Shorki's request —
          # matches the shaderbg wallpaper): pink #ff218c, yellow #ffd800,
          # cyan #21b1ff, on deep plum neutrals.
          foreground = "#f2e9f4";
          background = "#1c1220";
          cursor = "#ff218c";
          cursor_text_color = "#1c1220";
          selection_background = "#21b1ff";
          selection_foreground = "#10131c";
          url_color = "#ffd800";
          active_border_color = "#ff218c";
          inactive_border_color = "#4a3550";
          color0 = "#2b1e33";
          color1 = "#ff218c";
          color2 = "#21b1ff";
          color3 = "#ffd800";
          color4 = "#21b1ff";
          color5 = "#ff5ca8";
          color6 = "#6fd3ff";
          color7 = "#e8ddef";
          color8 = "#5c4666";
          color9 = "#ff6fae";
          color10 = "#7fdbff";
          color11 = "#ffe14d";
          color12 = "#54c8ff";
          color13 = "#ff8fc0";
          color14 = "#a5e8ff";
          color15 = "#ffffff";
        };
      };
      # barbados 2026-11-01: SUPER+Q bind removed — the Omarchy
      # keybind layer claims SUPER+Q for close-window; the terminal
      # lives on SUPER+RETURN there.
      wayland.windowManager.hyprland.settings.bind = [ ];
    };
}
