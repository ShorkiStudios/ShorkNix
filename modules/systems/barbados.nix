# Barbados — Lenovo ThinkBook 15 G2 ITL (Intel Core i7-1165G7, Iris Xe).
#
# This file follows the repo's host-file pattern: the machine-generated
# hardware-configuration.nix from the fresh NixOS install, wrapped as
# { os = ...; }. The hardware-independent parts are filled in below; the
# generated parts are marked with a placeholder block and MUST be merged
# in before the first build (see STAGING-NOTES.md).
#
# TODO (Muse PC Bridge): the bridge daemon (~/.local/lib/muse-pc-bridge)
# plus its Tailscale Funnel / Cloudflare tunnel doors are NOT declared
# here yet. They were a hand-rolled setup on the old Omarchy install and
# will be redeployed post-install, then folded into this config.
{
  os =
    {
      config,
      lib,
      modulesPath,
      pkgs,
      ...
    }:
    {
      imports = [
        (modulesPath + "/installer/scan/not-detected.nix")
      ];

      boot = {
        kernelModules = [ "kvm-intel" ];
        # Hibernate resume: the encrypted swap partition below.
        resumeDevice = "/dev/mapper/cryptswap";
        initrd = {
          availableKernelModules = [
            "xhci_pci"
            "thunderbolt"
            "nvme"
            "ahci"
            "uas"
            "usbhid"
            "sd_mod"
            "rtsx_pci_sdmmc"
          ];
          kernelModules = [ ];
          # Merged verbatim from the fresh install's generated config
          # (hardware-configuration.nix + the swap entry Calamares put
          # in configuration.nix), 2026-11-01. Root LUKS first, then the
          # swap LUKS.
          # Devices are referenced by GPT partition label, not UUID,
          # so rescue/repair work uses human-readable names (Shorki's
          # call, 2026-11-01). The installer had already partlabeled
          # p1 "EFI" and p2 "root"; p3 was named "swap" to match.
          # Mapping names are likewise plain: cryptroot / cryptswap.
          luks.devices = {
            "cryptroot".device = "/dev/disk/by-partlabel/root";
            "cryptswap".device = "/dev/disk/by-partlabel/swap";
          };
        };
        extraModulePackages = [ ];
      };

      # Filesystems — merged verbatim from the generated
      # hardware-configuration.nix, 2026-11-01 (btrfs on LUKS,
      # subvolumes for /home and /nix, vfat ESP).
      fileSystems = {
        "/" = {
          device = "/dev/mapper/cryptroot";
          fsType = "btrfs";
        };
        "/home" = {
          device = "/dev/mapper/cryptroot";
          fsType = "btrfs";
          options = [ "subvol=home" ];
        };
        "/nix" = {
          device = "/dev/mapper/cryptroot";
          fsType = "btrfs";
          options = [ "subvol=nix" ];
        };
        "/boot" = {
          device = "/dev/disk/by-partlabel/EFI";
          fsType = "vfat";
          options = [
            "fmask=0077"
            "dmask=0077"
          ];
        };
      };

      swapDevices = [
        { device = "/dev/mapper/cryptswap"; }
      ];

      # Intel Iris Xe (Tiger Lake GT2): accelerated graphics + VA-API
      # video decode via the Intel media driver.
      hardware.graphics = {
        enable = true;
        extraPackages = with pkgs; [
          intel-media-driver # VA-API driver for Iris Xe (iHD)
          intel-vaapi-driver # older VA-API driver (i965), kept for app compat
          libvdpau-va-gl
        ];
      };

      nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
      hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

      # Fingerprint reader: Elan 04f3:0c4b. Unlike tt0fu-laptop's
      # mainline sensor, this one needs the TOD (Touch OEM) driver stack.
      # Enroll after first boot with `fprintd-enroll`. Known quirk from
      # the old install: the sensor can fail right after wake-from-sleep
      # while it re-initializes — if that recurs on NixOS, escalate to a
      # resume hook that unbinds/rebinds USB device 04f3:0c4b.
      services.fprintd = {
        enable = true;
        tod = {
          enable = true;
          driver = pkgs.libfprint-2-tod1-elan;
        };
      };

      # Generated-config merge: DONE 2026-11-01 — LUKS devices,
      # fileSystems and swapDevices above were merged verbatim from
      # the fresh install's generated files (see STAGING-NOTES.md).
    };
}
