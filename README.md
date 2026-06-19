# ShorkNix

Personal NixOS configuration for `barbados` (Intel i7-1165G7 laptop).

- **WM:** [niri](https://github.com/YaLTeR/niri) — scrollable-tiling Wayland compositor
- **Shell:** [Noctalia](https://git.outfoxxed.me/quickshell/quickshell) — quickshell-based desktop shell
- **DM:** greetd (tuigreet)

Inspired by [tt0fu/nixos-config](https://github.com/tt0fu/nixos-config).

---

## Install

Boot the official [NixOS minimal ISO](https://nixos.org/download/), connect to the internet, then run the installer.

### 1. Connect WiFi

```bash
iwctl
# station wlan0 connect <your-ssid>
```

### 2. Run Installer

This erases the target disk and installs ShorkNix using LUKS, LVM, and btrfs. The script is fully automated except for the LUKS passphrase prompt.

```bash
sudo -i
nix-shell -p curl git parted cryptsetup lvm2 btrfs-progs dosfstools --run 'curl -L https://raw.githubusercontent.com/ShorkiStudios/ShorkNix/main/install.sh | bash -s -- /dev/nvme0n1'
```

Use a different disk path if needed, for example `/dev/sda`.

### 3. Reboot

When install completes:

```bash
reboot
```

First login:

| User | Password |
|---|---|
| `shork` | `shork` |

Change it immediately:

```bash
passwd
```

---

## Disk Layout

The installer creates this layout and the NixOS config refers to it by label:

| Partition | Size | Type | Mount |
|---|---|---|---|
| `NIXBOOT` | 1 GiB | EFI/vfat | `/boot` |
| `CRYPTROOT` | rest | LUKS2 | opened as `cryptroot` |
| `shorkvg/root` | remaining | btrfs label `NIXROOT` | `/`, `/home`, `/nix` subvols |
| `shorkvg/swap` | 16 GiB | swap label `NIXSWAP` | swap |

---

## After First Boot

Once NixOS is installed with ShorkNix:

```bash
# Set your git email (or edit modules/progs/essential/git.nix)
git config --global user.email "you@example.com"

# Rebuild with any changes
sudo ./build.sh switch
```

---

## Usage

| Command | What it does |
|---|---|
| `./build.sh switch` | Rebuild and switch to new config |
| `./build.sh boot` | Rebuild and set as boot default |
| `./update.sh` | Update flake lock, then rebuild |
| `./clean.sh` | Remove old generations, optimize store |

---

## Module Structure

Each module exports `{ os, home, deps }`:

- **`os`** — NixOS system configuration
- **`home`** — Home Manager user configuration
- **`deps`** — Other modules this one depends on (auto-resolved)

```
modules/
├── systems/barbados.nix   # hardware config (per-host)
├── core/                  # system-level: bootloader, nix, networking, etc.
├── de/niri/               # desktop environment: niri, greetd, noctalia
└── progs/essential/        # programs: git, zen-browser, alacritty, etc.
```
