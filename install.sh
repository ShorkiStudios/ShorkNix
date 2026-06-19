#!/usr/bin/env bash
set -euo pipefail

DISK="${1:-/dev/nvme0n1}"
HOSTNAME="barbados"
REPO_URL="https://github.com/ShorkiStudios/ShorkNix.git"
EFI_LABEL="NIXBOOT"
LUKS_LABEL="CRYPTROOT"
ROOT_LABEL="NIXROOT"
SWAP_LABEL="NIXSWAP"
LUKS_NAME="cryptroot"
VG_NAME="shorkvg"

part_path() {
    case "$DISK" in
        *[0-9]) printf "%sp%s" "$DISK" "$1" ;;
        *) printf "%s%s" "$DISK" "$1" ;;
    esac
}

need() {
    if ! command -v "$1" >/dev/null 2>&1; then
        echo "Error: missing required command: $1"
        exit 1
    fi
}

echo "=== ShorkNix Installer ==="
echo "Disk: $DISK"
echo ""

if [ "$(id -u)" -ne 0 ]; then
    echo "Error: run as root"
    exit 1
fi

if [ ! -b "$DISK" ]; then
    echo "Error: $DISK is not a block device"
    exit 1
fi

for cmd in btrfs cryptsetup lvcreate mkfs.btrfs mkfs.vfat mkswap mount nixos-install parted pvcreate swapon udevadm vgcreate; do
    need "$cmd"
done

EFI_PART="$(part_path 1)"
LUKS_PART="$(part_path 2)"
ROOT_LV="/dev/$VG_NAME/root"
SWAP_LV="/dev/$VG_NAME/swap"

echo "This will erase everything on $DISK."
echo "The installer is fully automated except for the LUKS passphrase prompts."
echo "You will create the passphrase, then enter it once more to unlock the disk for installation."
echo ""

swapoff -a 2>/dev/null || true
umount -R /mnt 2>/dev/null || true
vgchange -an "$VG_NAME" 2>/dev/null || true
cryptsetup close "$LUKS_NAME" 2>/dev/null || true

echo "=== Partitioning $DISK ==="
blkdiscard -f "$DISK" 2>/dev/null || true
parted "$DISK" -- mklabel gpt
parted "$DISK" -- mkpart ESP fat32 1MiB 1GiB
parted "$DISK" -- set 1 esp on
parted "$DISK" -- mkpart primary 1GiB 100%
udevadm settle

echo "=== Encrypting $LUKS_PART ==="
cryptsetup luksFormat --type luks2 --label "$LUKS_LABEL" "$LUKS_PART" < /dev/tty
cryptsetup open "$LUKS_PART" "$LUKS_NAME" < /dev/tty

echo "=== Setting up LVM ==="
pvcreate -ff -y "/dev/mapper/$LUKS_NAME"
vgcreate "$VG_NAME" "/dev/mapper/$LUKS_NAME"
lvcreate -L 23G -n swap "$VG_NAME"
lvcreate -l 100%FREE -n root "$VG_NAME"

echo "=== Formatting ==="
mkfs.vfat -F32 -n "$EFI_LABEL" "$EFI_PART"
mkswap -L "$SWAP_LABEL" "$SWAP_LV"
mkfs.btrfs -f -L "$ROOT_LABEL" "$ROOT_LV"
udevadm settle

echo "=== Creating btrfs subvolumes ==="
mount "$ROOT_LV" /mnt
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@nix
umount /mnt
udevadm settle

echo "=== Mounting ==="
mount -o noatime,compress=zstd:3,ssd,space_cache=v2,subvol=@ "/dev/disk/by-label/$ROOT_LABEL" /mnt
mkdir -p /mnt/{boot,home,nix}
mount "/dev/disk/by-label/$EFI_LABEL" /mnt/boot
mount -o noatime,compress=zstd:3,ssd,space_cache=v2,subvol=@home "/dev/disk/by-label/$ROOT_LABEL" /mnt/home
mount -o noatime,compress=zstd:3,ssd,space_cache=v2,subvol=@nix "/dev/disk/by-label/$ROOT_LABEL" /mnt/nix
swapon "/dev/disk/by-label/$SWAP_LABEL"

echo "=== Cloning ShorkNix ==="
mkdir -p /mnt/etc
nix-shell -p git --run "git clone $REPO_URL /mnt/etc/shorknix"

echo "=== Installing NixOS ==="
NIX_CONFIG="experimental-features = nix-command flakes" nixos-install --flake "/mnt/etc/shorknix#$HOSTNAME" --no-root-passwd

echo "=== Install complete ==="
echo "Reboot, log in as shork with password: shork"
echo "Run passwd after first login."
