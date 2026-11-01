# ShorkNix 🦈

![pink](https://img.shields.io/badge/-FF218C-FF218C?style=flat-square) ![yellow](https://img.shields.io/badge/-FFD800-FFD800?style=flat-square) ![cyan](https://img.shields.io/badge/-21B1FF-21B1FF?style=flat-square) ![NixOS](https://img.shields.io/badge/NixOS-26.11-5277C3?style=flat-square&logo=nixos&logoColor=white) ![Hyprland](https://img.shields.io/badge/Hyprland-0.56-58E1FF?style=flat-square)

My NixOS config for **barbados**, my Lenovo ThinkBook 15 G2 ITL (i7-1165G7, Iris Xe).

> **Credit where it's due:** the foundation of this repo — the module system, the Hyprland + quickshell desktop, and most of the tree — is [**tt0fu/nixos-config**](https://github.com/tt0fu/nixos-config) by **tt0fu**. This repo is their config with my machine and my layers added on top. The base is theirs; the barbados-specific parts are mine.

## What's mine on top

- **Omarchy keybinds**, ported wholesale — press `SUPER + K` on the machine for the full helper page (it opens as its own window)
- **Parity layer** — the package set from my old Arch/Omarchy system, rebuilt as a Nix module: apps, CLI tools, emulators, flatpaks
- **Pansexual flag theme everywhere** — `#FF218C` / `#FFD800` / `#21B1FF`: the shaderbg live wallpaper (an fbm shader, not a picture), kitty, the oh-my-posh prompt, even the fastfetch Nix logo
- **A tunnel service** so my assistant can reach the machine — the token lives outside this repo, in `~/.config/cloudflared/`
- **No live switches for big jumps** — boot + reboot, learned the hard way on install day (RIP swap.target)

## The only commands I actually run

| Command | What it does |
|---|---|
| `bb` | Build. Then auto-commit + push whatever changed |
| `bbs` | Build and switch live, session stays open. Then auto-commit + push |
| `bbr` | Build, switch, soft-reboot (no LUKS prompt, apps close). Refuses if the kernel changed |
| `bbt` | Build and stage for the next full boot |

Every build leaves the git tree clean, because the scripts commit the result themselves.
Yes, `result` is tracked on purpose. No, I won't gitignore it. It's fine.

## Layout

- `modules/systems/` — per-machine config (barbados: hardware, LUKS/btrfs by-partlabel, fingerprint reader)
- `modules/core/` — the base system
- `modules/de/` — Hyprland + quickshell desktop, shaderbg wallpaper, lock screen
- `modules/progs/` — program trees; mine are `parity`, `keybinds`, `shortcuts`, `tunnel`
- `settings.nix` — which trees are selected for barbados

## Notes

- Disks are referenced by GPT partlabel (`EFI`, `root`, `swap`) — no UUIDs, so the config still makes sense in a repair shell
- This is a personal config, not a distro. It will not work on your machine, and that's okay

## Credits

- **[tt0fu](https://github.com/tt0fu)** — [tt0fu/nixos-config](https://github.com/tt0fu/nixos-config), the base this whole repo stands on: the nixos-builder module system, the desktop layer, and the bulk of the modules. If you like the structure here, star their repo, not this one.
- **[Omarchy](https://omarchy.org)** — where my keybinds (and my previous system) came from; the bind layer here is a port of theirs.
- **Hyprland, quickshell, and the NixOS community** — the pieces underneath everything.
