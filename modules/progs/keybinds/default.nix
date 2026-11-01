# Barbados keybind layer — Shorki's Omarchy keybinds, ported.
#
# Source of truth: ~/workspace/nixos/keybind-mapping.md (compiled
# 2026-11-01 from upstream Omarchy's default/hypr/bindings/*.lua plus
# Shorki's personal overrides recovered from his Omarchy backup,
# bindings.lua.bak-20261027-rebound). Approved by Shorki 2026-11-01
# ("DO IT") with the map's recommended resolutions: Omarchy keys win
# every conflict, tt0fu's power trio (SUPER+CTRL+SHIFT+P/L/ESCAPE) is
# deleted, and the useful tt0fu extras stay.
#
# Conflicting tt0fu binds were removed/changed at their source
# modules (see "barbados" comments in de/hyprland.nix,
# de/quickshell/default.nix, de/screenshot.nix,
# progs/essential/kitty.nix, progs/coding/zeditor/default.nix,
# progs/social/{telegram,signal,discord}.nix, progs/utils/btop.nix),
# so every combo below is bound exactly once.
#
# This module also generates the SUPER+K helper page
# (~/.local/share/keybinds.html) from the same bind table, so the
# page can never drift from the real binds.
#
# Deliberately NOT ported:
# - SUPER+CTRL+D (his shorki-displays GUI): it writes
#   ~/.config/hypr/monitors.lua, which nothing reads under NixOS —
#   monitors are declared in settings.nix instead.
# - SUPER+CTRL+L's lock-with-screensaver script: hard Omarchy
#   dependencies (omarchy-system-lock, his lock plugin). The key
#   locks via quickshell instead.
# - SUPER+CTRL+S screensaver: no screensaver exists here; the key
#   locks (closest equivalent), noted on the helper page.
{
  home =
    { lib, ... }:
    let
      # One record per bind: key combo, human description (helper
      # page), and the Lua dispatcher expression. opts mirrors the
      # third _args element used elsewhere in this tree
      # ({ locked = true; } etc.).
      binds = [
        # --- Apps & shell ---
        {
          key = "SUPER + RETURN";
          desc = "Terminal (kitty)";
          lua = ''hl.dsp.exec_cmd("kitty")'';
        }
        {
          key = "SUPER + SHIFT + RETURN";
          desc = "Browser (Zen)";
          lua = ''hl.dsp.exec_cmd("zen-twilight")'';
        }
        {
          key = "SUPER + SHIFT + B";
          desc = "Browser (Zen)";
          lua = ''hl.dsp.exec_cmd("zen-twilight")'';
        }
        {
          key = "SUPER + SHIFT + ALT + B";
          desc = "Browser, private window";
          lua = ''hl.dsp.exec_cmd("zen-twilight --private-window")'';
        }
        {
          key = "SUPER + SPACE";
          desc = "App launcher";
          lua = ''hl.dsp.global("quickshell:toggleLauncher")'';
        }
        {
          key = "SUPER + K";
          desc = "Keybind helper page (this page)";
          lua = ''hl.dsp.exec_cmd("xdg-open $HOME/.local/share/keybinds.html")'';
        }
        {
          key = "SUPER + CTRL + L";
          desc = "Lock screen";
          lua = ''hl.dsp.global("quickshell:lock")'';
        }
        {
          key = "SUPER + CTRL + S";
          desc = "Screensaver (locks the screen — no separate screensaver here)";
          lua = ''hl.dsp.global("quickshell:lock")'';
        }
        {
          key = "SUPER + SHIFT + F";
          desc = "File manager (Nautilus)";
          lua = ''hl.dsp.exec_cmd("nautilus")'';
        }
        {
          key = "SUPER + SHIFT + N";
          desc = "Editor (Zed)";
          lua = ''hl.dsp.exec_cmd("zeditor")'';
        }
        {
          key = "SUPER + SHIFT + M";
          desc = "Music (Spotify)";
          lua = ''hl.dsp.exec_cmd("spotify")'';
        }
        {
          key = "SUPER + SHIFT + SLASH";
          desc = "Passwords (KeePassXC)";
          lua = ''hl.dsp.exec_cmd("keepassxc")'';
        }
        {
          key = "SUPER + CTRL + V";
          desc = "Clipboard manager";
          lua = ''hl.dsp.global("quickshell:toggleClipboard")'';
        }
        {
          key = "SUPER + Print";
          desc = "Color picker";
          lua = ''hl.dsp.exec_cmd("hyprpicker -a")'';
        }

        # --- Windows & workspaces ---
        {
          key = "SUPER + W";
          desc = "Close window";
          lua = ''hl.dsp.window.close()'';
        }
        {
          key = "SUPER + Q";
          desc = "Close window";
          lua = ''hl.dsp.window.close()'';
        }
        {
          key = "SUPER + J";
          desc = "Toggle window split";
          lua = ''hl.dsp.layout("togglesplit")'';
        }
        {
          key = "SUPER + P";
          desc = "Pseudo window";
          lua = ''hl.dsp.window.pseudo()'';
        }
        {
          key = "SUPER + T";
          desc = "Float / unfloat window";
          lua = ''hl.dsp.window.float()'';
        }
        {
          key = "SUPER + F";
          desc = "Fullscreen";
          lua = ''hl.dsp.window.fullscreen()'';
        }
        {
          key = "SUPER + ALT + F";
          desc = "Full width (maximized)";
          lua = ''hl.dsp.window.fullscreen({ mode = "maximized" })'';
        }
        {
          key = "SUPER + S";
          desc = "Toggle scratchpad";
          lua = ''hl.dsp.workspace.toggle_special("scratchpad")'';
        }
        {
          key = "SUPER + grave";
          desc = "Toggle scratchpad";
          lua = ''hl.dsp.workspace.toggle_special("scratchpad")'';
        }
        {
          key = "SUPER + ALT + S";
          desc = "Move window to scratchpad";
          lua = ''hl.dsp.window.move({ follow = false, workspace = "special:scratchpad" })'';
        }
        {
          key = "SUPER + SHIFT + grave";
          desc = "Move window to scratchpad";
          lua = ''hl.dsp.window.move({ follow = false, workspace = "special:scratchpad" })'';
        }
        {
          key = "SUPER + TAB";
          desc = "Next workspace";
          lua = ''hl.dsp.focus({ workspace = "e+1" })'';
        }
        {
          key = "SUPER + SHIFT + TAB";
          desc = "Previous workspace";
          lua = ''hl.dsp.focus({ workspace = "e-1" })'';
        }
        {
          key = "SUPER + CTRL + TAB";
          desc = "Former workspace";
          lua = ''hl.dsp.focus({ workspace = "previous" })'';
        }
        {
          key = "ALT + TAB";
          desc = "Cycle to next window";
          lua = ''function() hl.dispatch(hl.dsp.window.cycle_next()); hl.dispatch(hl.dsp.window.bring_to_top()) end'';
        }
        {
          key = "ALT + SHIFT + TAB";
          desc = "Cycle to previous window";
          lua = ''function() hl.dispatch(hl.dsp.window.cycle_next({ next = false })); hl.dispatch(hl.dsp.window.bring_to_top()) end'';
        }
        {
          key = "CTRL + ALT + TAB";
          desc = "Focus next monitor";
          lua = ''hl.dsp.focus({ monitor = "+1" })'';
        }
        {
          key = "CTRL + ALT + SHIFT + TAB";
          desc = "Focus previous monitor";
          lua = ''hl.dsp.focus({ monitor = "-1" })'';
        }
        {
          key = "SUPER + 0";
          desc = "Workspace 10";
          lua = ''hl.dsp.focus({ workspace = 10 })'';
        }
        {
          key = "SUPER + SHIFT + 0";
          desc = "Move window to workspace 10";
          lua = ''hl.dsp.window.move({ workspace = 10 })'';
        }

        # --- Notifications ---
        {
          key = "SUPER + comma";
          desc = "Dismiss last notification";
          lua = ''hl.dsp.exec_cmd("dunstctl close")'';
        }
        {
          key = "SUPER + SHIFT + comma";
          desc = "Dismiss all notifications";
          lua = ''hl.dsp.exec_cmd("dunstctl close-all")'';
        }
        {
          key = "SUPER + CTRL + comma";
          desc = "Silence / unsilence notifications";
          lua = ''hl.dsp.exec_cmd("dunstctl set-paused toggle")'';
        }
        {
          key = "SUPER + ALT + comma";
          desc = "Notifications panel";
          lua = ''hl.dsp.global("quickshell:toggleNotifications")'';
        }
        {
          key = "SUPER + SHIFT + ALT + comma";
          desc = "Notification history";
          lua = ''hl.dsp.global("quickshell:toggleNotifications")'';
        }

        # --- Zoom ---
        {
          key = "SUPER + CTRL + Z";
          desc = "Zoom in";
          lua = ''hl.dsp.exec_cmd("hyprctl keyword cursor:zoom_factor 2")'';
        }
        {
          key = "SUPER + CTRL + ALT + Z";
          desc = "Reset zoom";
          lua = ''hl.dsp.exec_cmd("hyprctl keyword cursor:zoom_factor 1")'';
        }

        # --- Media additions (base transport/volume keys live in
        # de/hyprland.nix, now with locked/repeating flags) ---
        {
          key = "XF86AudioPause";
          desc = "Play / pause";
          lua = ''hl.dsp.exec_cmd("playerctl play-pause")'';
          opts = { locked = true; };
        }
        {
          key = "ALT + XF86AudioPlay";
          desc = "Next track";
          lua = ''hl.dsp.exec_cmd("playerctl next")'';
          opts = { locked = true; };
        }
        {
          key = "ALT + SHIFT + XF86AudioPlay";
          desc = "Previous track";
          lua = ''hl.dsp.exec_cmd("playerctl previous")'';
          opts = { locked = true; };
        }
        {
          key = "ALT + XF86AudioRaiseVolume";
          desc = "Volume up, fine (1%)";
          lua = ''hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 1%+ --limit 1.5")'';
          opts = { locked = true; repeating = true; };
        }
        {
          key = "ALT + XF86AudioLowerVolume";
          desc = "Volume down, fine (1%)";
          lua = ''hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 1%-")'';
          opts = { locked = true; repeating = true; };
        }
        {
          key = "ALT + XF86MonBrightnessUp";
          desc = "Brightness up, fine (1%)";
          lua = ''hl.dsp.exec_cmd("brightnessctl s +1%")'';
          opts = { locked = true; repeating = true; };
        }
        {
          key = "ALT + XF86MonBrightnessDown";
          desc = "Brightness down, fine (1%)";
          lua = ''hl.dsp.exec_cmd("brightnessctl s 1%-")'';
          opts = { locked = true; repeating = true; };
        }
        {
          key = "SHIFT + XF86MonBrightnessUp";
          desc = "Brightness maximum";
          lua = ''hl.dsp.exec_cmd("brightnessctl s 100%")'';
          opts = { locked = true; };
        }
        {
          key = "SHIFT + XF86MonBrightnessDown";
          desc = "Brightness minimum";
          lua = ''hl.dsp.exec_cmd("brightnessctl s 1%")'';
          opts = { locked = true; };
        }

        # --- Window groups ---
        {
          key = "SUPER + G";
          desc = "Toggle window grouping";
          lua = ''hl.dsp.group.toggle()'';
        }
        {
          key = "SUPER + ALT + G";
          desc = "Move window out of group";
          lua = ''hl.dsp.window.move({ out_of_group = true })'';
        }
        {
          key = "SUPER + ALT + TAB";
          desc = "Next window in group";
          lua = ''hl.dsp.group.next()'';
        }
        {
          key = "SUPER + ALT + SHIFT + TAB";
          desc = "Previous window in group";
          lua = ''hl.dsp.group.prev()'';
        }
        {
          key = "SUPER + CTRL + Left";
          desc = "Group focus previous";
          lua = ''hl.dsp.group.prev()'';
        }
        {
          key = "SUPER + CTRL + Right";
          desc = "Group focus next";
          lua = ''hl.dsp.group.next()'';
        }
      ]
      # Move window into group, directionally.
      ++ map
        (dir: {
          key = "SUPER + ALT + ${dir}";
          desc = "Move window into group (${lib.toLower dir})";
          lua = ''hl.dsp.window.move({ into_group = "${lib.toLower dir}" })'';
        })
        [ "Left" "Right" "Up" "Down" ]
      # Switch to group window N (1-5).
      ++ builtins.genList
        (i: {
          key = "SUPER + ALT + ${toString (i + 1)}";
          desc = "Group window ${toString (i + 1)}";
          lua = ''hl.dsp.group.active({ index = ${toString (i + 1)} })'';
        })
        5
      # Move window to workspace N silently (1-10; 10 is on 0).
      ++ builtins.genList
        (i: {
          key = "SUPER + SHIFT + ALT + ${if i == 9 then "0" else toString (i + 1)}";
          desc = "Move window to workspace ${toString (i + 1)} (silently)";
          lua = ''hl.dsp.window.move({ follow = false, workspace = ${toString (i + 1)} })'';
        })
        10
      # Move workspace to monitor, directionally (hyprctl classic
      # dispatcher — the Lua API has no direct equivalent here).
      ++ map
        (dir: {
          key = "SUPER + SHIFT + ALT + ${dir}";
          desc = "Move workspace to monitor (${lib.toLower dir})";
          lua = ''hl.dsp.exec_cmd("hyprctl dispatch movecurrentworkspacetomonitor ${lib.toLower dir}")'';
        })
        [ "Left" "Right" "Up" "Down" ]
      # Resize binds: -/= keys next to Backspace (code:20 / code:21).
      # Plain = width 100px steps, SHIFT = height 100px, ALT adds
      # 25px fine steps, CTRL adds 300px coarse steps.
      ++ lib.concatLists (
        map
          (step: [
            {
              key = "SUPER + ${step.mods}code:20";
              desc = "Resize ${step.axis} -${step.px}px";
              lua = ''hl.dsp.window.resize({ relative = true, ${step.axis} = -${step.px} })'';
            }
            {
              key = "SUPER + ${step.mods}code:21";
              desc = "Resize ${step.axis} +${step.px}px";
              lua = ''hl.dsp.window.resize({ relative = true, ${step.axis} = ${step.px} })'';
            }
          ])
          [
            { mods = ""; axis = "x"; px = "100"; }
            { mods = "SHIFT + "; axis = "y"; px = "100"; }
            { mods = "ALT + "; axis = "x"; px = "25"; }
            { mods = "ALT + SHIFT + "; axis = "y"; px = "25"; }
            { mods = "CTRL + "; axis = "x"; px = "300"; }
            { mods = "CTRL + SHIFT + "; axis = "y"; px = "300"; }
          ]
      );

      # Binds that live in other modules (kept tt0fu binds and the
      # source-edited ones) — listed so the helper page is complete.
      kept = [
        { key = "SUPER + 1 … 9"; desc = "Switch to workspace"; }
        { key = "SUPER + SHIFT + 1 … 9"; desc = "Move window to workspace"; }
        { key = "SUPER + arrows"; desc = "Focus window directionally"; }
        { key = "SUPER + SHIFT + arrows"; desc = "Swap window directionally"; }
        { key = "SUPER + ESCAPE"; desc = "Close window"; }
        { key = "SUPER + SHIFT + ESCAPE"; desc = "Kill window"; }
        { key = "SUPER + D"; desc = "Discord (Legcord)"; }
        { key = "SUPER + E"; desc = "File manager (Nautilus)"; }
        { key = "SUPER + M"; desc = "Task manager (Mission Center)"; }
        { key = "SUPER + N"; desc = "Notifications panel"; }
        { key = "SUPER + Z"; desc = "Browser (Zen)"; }
        { key = "SUPER + X"; desc = "Mail (Thunderbird)"; }
        { key = "SUPER + SHIFT + E"; desc = "File manager, terminal (yazi)"; }
        { key = "SUPER + SHIFT + G"; desc = "Signal"; }
        { key = "SUPER + CTRL + T"; desc = "Activity monitor (btop)"; }
        { key = "SUPER + Caps_Lock"; desc = "Next keyboard layout"; }
        { key = "SUPER + SHIFT + Caps_Lock"; desc = "Previous keyboard layout"; }
        { key = "Print"; desc = "Screenshot, area"; }
        { key = "SHIFT + Print"; desc = "Screenshot, full screen"; }
        { key = "XF86AudioRaiseVolume / LowerVolume"; desc = "Volume up / down (5%)"; }
        { key = "XF86AudioMute"; desc = "Mute toggle"; }
        { key = "XF86AudioMicMute"; desc = "Microphone mute toggle"; }
        { key = "XF86AudioPlay / Pause"; desc = "Play / pause"; }
        { key = "XF86AudioNext / Prev"; desc = "Next / previous track"; }
        { key = "XF86AudioStop"; desc = "Stop playback"; }
        { key = "XF86MonBrightnessUp / Down"; desc = "Brightness up / down (5%)"; }
        { key = "SUPER + drag left mouse"; desc = "Move window"; }
        { key = "SUPER + drag right mouse"; desc = "Resize window"; }
        { key = "SUPER + middle click"; desc = "Close window"; }
        { key = "SUPER + mouse wheel"; desc = "Focus window left / right"; }
        { key = "3-finger swipe ↔"; desc = "Scroll windows"; }
        { key = "4-finger swipe ↔"; desc = "Switch workspace"; }
      ];

      esc = lib.replaceStrings [ "&" "<" ">" ] [ "&amp;" "&lt;" "&gt;" ];
      row = b: "<tr><td class=\"k\">${esc b.key}</td><td>${esc b.desc}</td></tr>\n";
      rows = list: lib.concatMapStrings row list;

      page = ''
        <!DOCTYPE html>
        <html lang="en"><head><meta charset="utf-8">
        <title>Barbados keybinds</title>
        <style>
          body { background:#11131a; color:#dfe3ee; font:15px/1.5 system-ui,sans-serif; margin:2rem auto; max-width:52rem; padding:0 1rem; }
          h1 { font-size:1.5rem; } h2 { font-size:1.1rem; margin-top:2rem; color:#9db4ff; }
          table { border-collapse:collapse; width:100%; }
          td { border-bottom:1px solid #262a38; padding:.3rem .6rem; vertical-align:top; }
          td.k { font-family:ui-monospace,monospace; white-space:nowrap; color:#ffd479; width:45%; }
          p.note { color:#9aa3b8; }
        </style></head><body>
        <h1>Barbados keybinds</h1>
        <p class="note">Your Omarchy keybinds, ported to the NixOS setup. Generated from the same
        table the binds are built from, so this page always matches reality. SUPER is the Windows key.</p>
        <h2>Keybind layer (Omarchy)</h2>
        <table>${rows binds}</table>
        <h2>Kept from the base setup</h2>
        <table>${rows kept}</table>
        <p class="note">Not ported: SUPER+CTRL+D (your displays GUI — NixOS declares monitors in the
        config instead). SUPER+CTRL+S locks the screen; there is no separate screensaver in this setup.
        Power actions (shutdown / reboot / log out) live on the login screen and the bar — the old
        SUPER+CTRL+SHIFT+P/L/ESCAPE chords were removed on purpose.</p>
        </body></html>
      '';
    in
    {
      wayland.windowManager.hyprland.settings.bind =
        map
          (b: {
            _args = [ b.key (lib.generators.mkLuaInline b.lua) ]
              ++ lib.optional (b ? opts) b.opts;
          })
          binds;

      home.file.".local/share/keybinds.html".text = page;
    };
}
