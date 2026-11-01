{
  inputs = {
    quickshell = {
      url = "github:quickshell-mirror/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  home =
    {
      inputs,
      lib,
      pkgs,
      ...
    }:
    {
      programs.quickshell = {
        enable = true;
        # package = inputs.quickshell.packages.${pkgs.stdenv.hostPlatform.system}.default;
        activeConfig = "shell";
        configs = {
          shell = ./shell;
        };
      };
      wayland.windowManager.hyprland.settings = {
        layer_rule = [
          {
            match = {
              namespace = "quickshell";
            };
            blur = true;
            blur_popups = true;
            ignore_alpha = 0.0;
          }
        ];
        bind = [
          # barbados 2026-11-01: SUPER+A (launcher), SUPER+V
          # (clipboard) and SUPER+L (lock) binds removed — the
          # Omarchy keybind layer puts the launcher on SUPER+SPACE,
          # clipboard on SUPER+CTRL+V, and lock on SUPER+CTRL+L.
          # SUPER+N notifications stays.
          {
            _args = [
              "SUPER + N"
              (lib.generators.mkLuaInline "hl.dsp.global(\"quickshell:toggleNotifications\")")
            ];
          }
        ];
        on = [
          {
            _args = [
              "hyprland.start"
              (lib.generators.mkLuaInline ''function() hl.dispatch(hl.dsp.exec_cmd("quickshell -c shell", { tag = "do_not_close" })) end'')
            ];
          }
        ];
      };
    };
  deps =
    modules: with modules; [
      de.hyprshutdown
      progs.utils.nmgui
      progs.utils.libnotify
      progs.utils.cliphist
    ];
}
