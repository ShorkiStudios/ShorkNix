{
  inputs = {
    hyprland = {
      url = "github:hyprwm/Hyprland";
      # inputs.nixpkgs.follows = "nixpkgs";
    };
    hyprland-plugins = {
      url = "github:hyprwm/hyprland-plugins";
      inputs.hyprland.follows = "hyprland";
    };
    hypr-dynamic-cursors = {
      url = "github:VirtCode/hypr-dynamic-cursors";
      inputs.hyprland.follows = "hyprland";
    };
  };
  os =
    { inputs, pkgs, ... }:
    {
      hardware.graphics.enable = true;
      programs.hyprland = {
        enable = true;
        # package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.default;
        # portalPackage =
        #   inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
      };
      nix.settings = {
        substituters = [ "https://hyprland.cachix.org" ];
        trusted-substituters = [ "https://hyprland.cachix.org" ];
        trusted-public-keys = [ "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" ];
      };
    };
  home =
    {
      inputs,
      lib,
      systemSettings,
      style,
      pkgs,
      ...
    }:
    {
      home.packages = with pkgs; [
        glib
        hyprshot
        brightnessctl
        playerctl
      ];
      wayland.windowManager.hyprland = {
        enable = true;
        # package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.default;
        # portalPackage =
        #   inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
        plugins = [
          # pkgs.hyprlandPlugins.hypr-dynamic-cursors
          # inputs.hypr-dynamic-cursors.packages.${pkgs.stdenv.hostPlatform.system}.hypr-dynamic-cursors
        ];
        settings = {
          config = {
            general = {
              layout = "dwindle";
              border_size = style.border.thickness;
              gaps_in = style.spacing / 2;
              gaps_out = style.spacing;
              resize_on_border = true;
              "col.inactive_border" = "0xff808080";
              "col.active_border" = "0xffffffff";
            };
            decoration = {
              rounding = style.border.radius;
              blur = {
                # variant = "haze";
                size = 8;
                passes = 2;
                noise = 0.0;
                contrast = 1.0;
                brightness = 0.3;
                vibrancy = 0.0;
                popups = true;
                popups_ignorealpha = 0.2;
              };
              shadow.enabled = false;
            };
            input = {
              kb_layout = "us, ru";
              kb_options = "grp:alt_shift_toggle";
              touchpad.natural_scroll = true;
            };
            binds = {
              scroll_event_delay = 100;
            };
            misc = {
              disable_hyprland_logo = true;
              disable_splash_rendering = true;
              font_family = style.font.name;
              # enable_anr_dialog = false;
              anr_missed_pings = 10;
              middle_click_paste = false;
              session_lock_xray = true;
              session_lock_blur = true;
            };
            dwindle = {
              smart_split = true;
            };
            scrolling = {
              column_width = 0.5;
              fullscreen_on_one_column = true;
            };
            master = {
              allow_small_split = true;
            };
            ecosystem = {
              no_donation_nag = true;
              no_update_news = true;
            };
          };
          monitor = with systemSettings.monitor; {
            output = name;
            mode = "${toString width}x${toString height}@${toString framerate}";
            position = "${toString x}x${toString y}";
            inherit scale;
          };
          bind = [
            {
              _args = [
                "SUPER + Caps_Lock"
                (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("hyprctl switchxkblayout main next")'')
              ];
            }
            {
              _args = [
                "SUPER + SHIFT + Caps_Lock"
                (lib.generators.mkLuaInline ''hl.dsp.exec_cmd("hyprctl switchxkblayout main prev")'')
              ];
            }
            {
              _args = [
                "SUPER + ESCAPE"
                (lib.generators.mkLuaInline "hl.dsp.window.close()")
              ];
            }
            {
              _args = [
                "SUPER + SHIFT + ESCAPE"
                (lib.generators.mkLuaInline "hl.dsp.window.kill()")
              ];
            }
            {
              _args = [
                "SUPER + mouse:274"
                (lib.generators.mkLuaInline "hl.dsp.window.close()")
              ];
            }
            {
              _args = [
                "SUPER + SHIFT + mouse:274"
                (lib.generators.mkLuaInline "hl.dsp.window.kill()")
              ];
            }
            # barbados 2026-11-01: SUPER+SPACE (was float), SUPER+RETURN
            # (was fullscreen), SUPER+TAB / SUPER+SHIFT+TAB (was window
            # cycling) binds removed — the Omarchy keybind layer claims
            # all four: launcher, terminal, next/previous workspace.
            # Float lives on SUPER+T and fullscreen on SUPER+F there.
            # barbados 2026-11-01: the SUPER+CTRL+SHIFT+P/L/ESCAPE
            # power trio (shutdown/reboot/logout) removed at Shorki's
            # call — SUPER+CTRL+SHIFT+L sat one Shift away from his
            # SUPER+CTRL+L lock key. Power actions live on the greetd
            # screen and the bar.
            {
              _args = [
                "SUPER + Up"
                (lib.generators.mkLuaInline "hl.dsp.focus({ direction = \"up\" })")
              ];
            }
            {
              _args = [
                "SUPER + Down"
                (lib.generators.mkLuaInline "hl.dsp.focus({ direction = \"down\" })")
              ];
            }
            {
              _args = [
                "SUPER + Left"
                (lib.generators.mkLuaInline "hl.dsp.layout(\"focus l\")")
              ];
            }
            {
              _args = [
                "SUPER + Right"
                (lib.generators.mkLuaInline "hl.dsp.layout(\"focus r\")")
              ];
            }
            {
              _args = [
                "SUPER + mouse_down"
                (lib.generators.mkLuaInline "hl.dsp.layout(\"focus l\")")
              ];
            }
            {
              _args = [
                "SUPER + mouse_up"
                (lib.generators.mkLuaInline "hl.dsp.layout(\"focus r\")")
              ];
            }
            {
              _args = [
                "SUPER + mouse:276"
                (lib.generators.mkLuaInline "hl.dsp.focus({ workspace = \"e-1\" })")
              ];
            }
            {
              _args = [
                "SUPER + mouse:275"
                (lib.generators.mkLuaInline "hl.dsp.focus({ workspace = \"e+1\" })")
              ];
            }
            {
              _args = [
                "SUPER + SHIFT + Up"
                (lib.generators.mkLuaInline "hl.dsp.window.swap({ direction = \"up\" })")
              ];
            }
            {
              _args = [
                "SUPER + SHIFT + Down"
                (lib.generators.mkLuaInline "hl.dsp.window.swap({ direction = \"down\" })")
              ];
            }
            {
              _args = [
                "SUPER + SHIFT + Left"
                (lib.generators.mkLuaInline "hl.dsp.window.swap({ direction = \"left\" })")
              ];
            }
            {
              _args = [
                "SUPER + SHIFT + Right"
                (lib.generators.mkLuaInline "hl.dsp.window.swap({ direction = \"right\" })")
              ];
            }
            {
              _args = [
                "XF86AudioLowerVolume"
                (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-\")")
                { locked = true; repeating = true; }
              ];
            }
            {
              _args = [
                "XF86AudioRaiseVolume"
                (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+ --limit 1.5\")")
                { locked = true; repeating = true; }
              ];
            }
            {
              _args = [
                "XF86AudioMute"
                (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle\")")
                { locked = true; }
              ];
            }
            {
              _args = [
                "XF86AudioMicMute"
                (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle\")")
                { locked = true; }
              ];
            }
            {
              _args = [
                "XF86AudioPlay"
                (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"playerctl play-pause\")")
                { locked = true; }
              ];
            }
            {
              _args = [
                "XF86AudioStop"
                (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"playerctl stop\")")
                { locked = true; }
              ];
            }
            {
              _args = [
                "XF86AudioPrev"
                (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"playerctl previous\")")
                { locked = true; }
              ];
            }
            {
              _args = [
                "XF86AudioNext"
                (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"playerctl next\")")
                { locked = true; }
              ];
            }
            {
              _args = [
                "XF86MonBrightnessDown"
                (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"brightnessctl s 5%-\")")
                { locked = true; repeating = true; }
              ];
            }
            {
              _args = [
                "XF86MonBrightnessUp"
                (lib.generators.mkLuaInline "hl.dsp.exec_cmd(\"brightnessctl s +5%\")")
                { locked = true; repeating = true; }
              ];
            }
            {
              _args = [
                "SUPER + mouse:272"
                (lib.generators.mkLuaInline "hl.dsp.window.drag()")
                { mouse = true; }
              ];
            }
            {
              _args = [
                "SUPER + mouse:273"
                (lib.generators.mkLuaInline "hl.dsp.window.resize()")
                { mouse = true; }
              ];
            }
          ]
          ++ (builtins.concatLists (
            builtins.genList (i: [
              {
                _args = [
                  "SUPER + ${toString (i + 1)}"
                  (lib.generators.mkLuaInline "hl.dsp.focus({ workspace = ${toString (i + 1)} })")
                ];
              }
              {
                _args = [
                  "SUPER + SHIFT + ${toString (i + 1)}"
                  (lib.generators.mkLuaInline "hl.dsp.window.move({ workspace = ${toString (i + 1)} })")
                ];
              }
            ]) 9
          ));
          gesture = [
            {
              fingers = 3;
              direction = "horizontal";
              action = "scroll_move";
            }
            {
              fingers = 4;
              direction = "horizontal";
              action = "workspace";
            }
          ];
          animation = [
            {
              leaf = "global";
              enabled = true;
              speed = 1;
              bezier = "easeInOutQuad";
            }
          ];
          curve = [
            {
              _args = [
                "easeInOutQuad"
                (lib.generators.mkLuaInline ''{ type = "bezier", points = { {0.45, 0}, {0.55, 1} } }'')
              ];
            }
          ];
          window_rule = [
            {
              match = {
                focus = false;
              };
              render_unfocused = true;
            }
          ];
          # plugin = {
          #   dynamic-cursors = {
          #     mode = "stretch";
          #     stretch = {
          #       limit = 15000;
          #     };
          #     shake = {
          #       threshold = 7.5;
          #       effects = true;
          #       timeout = 1500;
          #     };
          #     hyprcursor = {
          #       nearest = false;
          #     };
          #   };
          # };
        };
      };
      home.sessionVariables = {
        NIXOS_OZONE_WL = "1";
      };
      programs.hyprtoolkit = {
        enable = true;
        settings = {
          background = "0x01000000";
          accent = "0xFFFFFFFF";
          accent_secondary = "0xFFFFFFFF";
          font_family = style.font.name;
        };
      };
    };
  deps = modules: with modules; [ de.hyprshutdown ];
}
