#!/usr/bin/env bash
set -euo pipefail

DISK="${1:-/dev/nvme0n1}"
HOSTNAME="barbados"
REPO_URL="https://github.com/ShorkiStudios/ShorkNix"

echo "=== ShorkNix Installer ==="
echo "Disk: $DISK"
echo ""

if [ ! -b "$DISK" ]; then
    echo "Error: $DISK is not a block device"
    exit 1
fi

echo "=== Partitioning $DISK ==="
blkdiscard -f "$DISK" 2>/dev/null || true
parted "$DISK" -- mklabel gpt
parted "$DISK" -- mkpart ESP fat32 1MiB 1GiB
parted "$DISK" -- set 1 esp on
parted "$DISK" -- mkpart primary 1GiB 100%

EFI_PART="${DISK}p1"
LUKS_PART="${DISK}p2"

echo "=== Encrypting $LUKS_PART ==="
cryptsetup luksFormat "$LUKS_PART"
cryptsetup open "$LUKS_PART" cryptroot

echo "=== Setting up LVM ==="
pvcreate /dev/mapper/cryptroot
vgcreate vg /dev/mapper/cryptroot
lvcreate -L 16G -n swap vg
lvcreate -l 100%FREE -n root vg

echo "=== Formatting ==="
mkfs.vfat -F32 "$EFI_PART"
mkswap /dev/vg/swap
mkfs.btrfs /dev/vg/root

echo "=== Creating btrfs subvolumes ==="
mount /dev/vg/root /mnt
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@nix
umount /mnt

echo "=== Mounting ==="
mount -o compress=zstd:3,subvol=@ /dev/vg/root /mnt
mkdir -p /mnt/{boot,home,nix}
mount "$EFI_PART" /mnt/boot
mount -o compress=zstd:3,subvol=@home /dev/vg/root /mnt/home
mount -o noatime,compress=zstd:3,subvol=@nix /dev/vg/root /mnt/nix
swapon /dev/vg/swap

echo "=== Generating hardware config ==="
nixos-generate-config --root /mnt

echo "=== Cloning ShorkNix ==="
nix-shell -p git --run "git clone $REPO_URL /mnt/etc/shorknix"

echo ""
echo "IMPORTANT: Copy hardware config into the repo:"
echo "  cp /mnt/etc/nixos/hardware-configuration.nix /mnt/etc/shorknix/modules/systems/$HOSTNAME.nix"
echo "  # Then edit it to wrap in { os = ...; }"
echo ""
echo "Then run:"
echo "  nixos-install --flake /mnt/etc/shorknix#$HOSTNAME"
