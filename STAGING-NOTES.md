# Staging notes — Barbados config (based on tt0fu/nixos-config)

Staged 2026-11-01 on the VM. This tree is a copy of upstream tt0fu
(excluding .git) with the Barbados adaptation applied. Nothing has been
pushed anywhere; this drops into the new repo Shorki creates.
flake.nix was NOT touched (in particular, nothing between the
GENERATED INPUTS markers).

## Changed vs upstream tt0fu

- `settings.nix`
  - `userSettings.username`: `ttofu` → `shork`.
  - New `systems.barbados` entry: x86_64-linux, America/Denver,
    en_US.UTF-8, monitor eDP-1 1920x1080@60 scale 1. Modules:
    systems.barbados, core, de, progs."3d", plus progs trees coding,
    essential, gaming, misc, networking, social, utils, video,
    virtualization, vr.
  - Upstream `ttofu-laptop` / `ttofu-pc` entries kept for reference;
    they are not built for Barbados.
- `modules/systems/barbados.nix` (NEW) — host file in the repo's
  `{ os = ...; }` pattern. Filled in: not-detected import, kvm-intel,
  the initrd module checklist (xhci_pci, thunderbolt, nvme, ahci, uas,
  usbhid, sd_mod, rtsx_pci_sdmmc), Intel microcode, Iris Xe graphics
  (hardware.graphics + intel-media-driver / intel-vaapi-driver /
  libvdpau-va-gl), and fingerprint (below).
- Fingerprint (in `modules/systems/barbados.nix`):
  `services.fprintd.enable` + `tod.enable` +
  `tod.driver = pkgs.libfprint-2-tod1-elan` for the Elan 04f3:0c4b
  sensor. (Upstream ttofu-laptop enables plain fprintd only.)
- `modules/progs/essential/git.nix` — added git identity:
  name "Shorki", email "shorkicalypso@gmail.com"
  (via `programs.git.settings.user`; upstream had none set).
- New extra modules (each rides along inside a module tree that the
  barbados entry already selects):
  - `modules/core/flatpak.nix` — `services.flatpak.enable`
    (needed for Unleashed Recomp; upstream has no flatpak anywhere).
  - `modules/progs/networking/tailscale.nix` — `services.tailscale.enable`
    (upstream ships wireguard only).
  - `modules/progs/utils/solaar.nix` — `hardware.logitech.wireless`
    with `enableGraphical` (Solaar for the MX Keys Mini / Bolt receiver).
  - `modules/progs/misc/spotify.nix` — nixpkgs spotify + an XDG desktop
    entry launching it with `--disable-gpu --ozone-platform=wayland`.
  - `modules/progs/social/legcord.nix` — `pkgs.legcord` as a home package.
  - `modules/progs/gaming/barbados-gaming-extras.nix` — intentionally
    empty module holding TODOs (see below).

## Still needs the generated hardware-configuration.nix

`modules/systems/barbados.nix` has a clearly-marked PLACEHOLDER block.
Before the first build, merge these from the fresh install's
`/etc/nixos/hardware-configuration.nix` on Barbados, verbatim —
no UUIDs were invented in staging:

- `boot.initrd.luks.devices.*` — LUKS is decided ON (installer ran
  erase-disk + encrypt). Without this the root disk won't unlock.
- `fileSystems."/"` (btrfs, with subvolume options) and
  `fileSystems."/boot"` (vfat ESP), plus any extra generated mounts.
- `swapDevices` (the swap-with-hibernate partition) and
  `boot.resumeDevice` if the generated file sets it.
- Any generated boot/initrd entries that differ from the checklist
  values in the host file (generated file wins).

Note: btrfs + LUKS means if the generated file already defines
conflicting keys with the checklist (e.g. duplicate availableKernelModules
is fine — lists merge), resolve in favour of the generated file.

## TODOs (also marked in-tree)

- **Parsec** — TODO comment in
  `modules/progs/gaming/barbados-gaming-extras.nix`. Not wired: check
  nixpkgs package + session persistence on the real machine first.
- **Resonite** — same file. App comes via Steam; the TODO is the data
  restore (headless/world data, `~/Resonite/start-headless.sh`) and
  recording any Proton/launch settings that prove necessary.
- **Game recomp ports / Alchemy viewer** — same file. Plain files
  restored from backup; `programs.nix-ld` is already enabled upstream
  (`modules/progs/utils/nix-ld.nix`). Extend its library list if a
  port needs more.
- **Muse PC Bridge** — TODO comment at the top of
  `modules/systems/barbados.nix`. Daemon + Tailscale Funnel / Cloudflare
  tunnel doors to be redeployed post-install and then declared.
- **Equicord** — TODO comment in `modules/progs/social/legcord.nix`.
  Legcord package is in; whether the restored profile carries
  Equicord or it needs explicit wiring is unverified.
- **LUKS header backup** — after the install settles, make a fresh
  LUKS header backup of the new root device and store it with the
  Omarchy backup on the "Not Really" drive (the old system's header
  backup does not apply to the new LUKS volume).

## Build-time watch items

- `social` is selected as a whole tree, so upstream's
  `social/discord.nix` (nixcord + vesktop) is included alongside
  Legcord. If both Discord clients aren't wanted, drop discord.nix
  or select social modules individually.
- `office` (OnlyOffice) exists upstream but is NOT in the barbados
  module list, matching the adaptation plan's starting set. Add
  `office` to the progs list in settings.nix if wanted.
- No nix evaluation was run during staging (this VM has no nix).
  First evaluation happens on Barbados via `./build.sh`.
- Post-boot: `fprintd-enroll` for the fingerprint; if unlock fails
  right after wake-from-sleep, see the resume-hook note in
  `modules/systems/barbados.nix`.
