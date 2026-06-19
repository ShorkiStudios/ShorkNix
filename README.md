# ShorkNix

Personal NixOS configuration for `barbados` (Intel i7-1165G7 laptop).

- **WM:** [niri](https://github.com/YaLTeR/niri) — scrollable-tiling Wayland compositor
- **Shell:** [Noctalia](https://git.outfoxxed.me/quickshell/quickshell) — quickshell-based desktop shell
- **DM:** greetd (tuigreet)

Inspired by [tt0fu/nixos-config](https://github.com/tt0fu/nixos-config).

---

## Fresh Install (from NixOS ISO)

### 1. Boot the ISO

Write the [NixOS minimal ISO](https://nixos.org/download/) to a USB, boot, and connect to WiFi:

```bash
iwctl
# station wlan0 connect <your-ssid>
```

### 2. Run the installer

```bash
sudo -i
curl -L https://raw.githubusercontent.com/ShorkiStudios/ShorkNix/main/install.sh | bash
```

Or do it manually (see [Manual Partitioning](#manual-partitioning) below).

### 3. Wrap the hardware config

After the installer clones the repo, copy the generated hardware config:

```bash
cp /mnt/etc/nixos/hardware-configuration.nix /mnt/etc/shorknix/modules/systems/barbados.nix
```

Edit `barbados.nix` and wrap it like this:

```nix
{
  os =
    { config, lib, modulesPath, ... }:

    {
      imports = [
        (modulesPath + "/installer/scan/not-detected.nix")
      ];

      # paste the rest of hardware-configuration.nix here
      boot.initrd.availableKernelModules = [ ... ];
      fileSystems."/" = ...;
      # etc.
    };
}
```

> **Note:** Remove any `nixpkgs.hostPlatform` and `boot.loader` lines from the copied config — those are already handled by the ShorkNix modules.

### 4. Install

```bash
nixos-install --flake /mnt/etc/shorknix#barbados
```

### 5. Reboot

```bash
reboot
```

---

## Manual Partitioning

If you prefer to partition by hand, use a layout matching this config:

| Partition | Size | Type | Mount |
|---|---|---|---|
| `nvme0n1p1` | 1 GiB | EFI (vfat) | `/boot` |
| `nvme0n1p2` | rest | LUKS → LVM → btrfs | `/` (subvol=@) |

```bash
DISK=/dev/nvme0n1

blkdiscard -f $DISK
parted $DISK -- mklabel gpt
parted $DISK -- mkpart ESP fat32 1MiB 1GiB
parted $DISK -- set 1 esp on
parted $DISK -- mkpart primary 1GiB 100%

cryptsetup luksFormat ${DISK}p2
cryptsetup open ${DISK}p2 cryptroot

pvcreate /dev/mapper/cryptroot
vgcreate vg /dev/mapper/cryptroot
lvcreate -L 16G -n swap vg
lvcreate -l 100%FREE -n root vg

mkfs.vfat -F32 ${DISK}p1
mkswap /dev/vg/swap
mkfs.btrfs /dev/vg/root

mount /dev/vg/root /mnt
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@nix
umount /mnt

mount -o compress=zstd:3,subvol=@ /dev/vg/root /mnt
mkdir -p /mnt/{boot,home,nix}
mount ${DISK}p1 /mnt/boot
mount -o compress=zstd:3,subvol=@home /dev/vg/root /mnt/home
mount -o noatime,compress=zstd:3,subvol=@nix /dev/vg/root /mnt/nix
swapon /dev/vg/swap

nixos-generate-config --root /mnt
git clone https://github.com/ShorkiStudios/ShorkNix.git /mnt/etc/shorknix
```

Then continue from [Wrap the hardware config](#3-wrap-the-hardware-config).

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

## Building a Live ISO

Build an ISO image of your system (including niri + noctalia):

```bash
nixos-rebuild build-image --image-variant iso --flake .#barbados
```

The ISO will be in `result/` — write to USB:

```bash
sudo dd if=result/*.iso of=/dev/sdX bs=4M status=progress
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
