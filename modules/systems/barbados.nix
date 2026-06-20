{
  os =
    { config, lib, pkgs, modulesPath, ... }:

    {
      imports = [
        (modulesPath + "/installer/scan/not-detected.nix")
      ];

      boot.initrd.availableKernelModules = [
        "xhci_pci"
        "thunderbolt"
        "ahci"
        "nvme"
        "uas"
        "usbhid"
        "sd_mod"
        "rtsx_pci_sdmmc"
      ];

      boot.initrd.luks.devices."cryptroot" = {
        device = "/dev/disk/by-label/cryptroot";
      };

      boot.initrd.services.lvm.enable = true;

      boot.initrd.kernelModules = [ "dm-snapshot" ];
      boot.kernelModules = [ "kvm-intel" ];
      boot.extraModulePackages = [ ];

      fileSystems."/" = {
        device = "/dev/mapper/vg-root";
        fsType = "btrfs";
        options = [ "subvol=@" ];
      };

      fileSystems."/boot" = {
        device = "/dev/disk/by-uuid/8852-1507";
        fsType = "vfat";
        options = [ "fmask=0022" "dmask=0022" ];
      };

      fileSystems."/home" = {
        device = "/dev/mapper/vg-root";
        fsType = "btrfs";
        options = [ "subvol=@home" ];
      };

      fileSystems."/nix" = {
        device = "/dev/mapper/vg-root";
        fsType = "btrfs";
        options = [ "subvol=@nix" ];
      };

      swapDevices = [
        {
          device = "/dev/mapper/vg-swap";
        }
      ];

      nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

      hardware.cpu.intel.updateMicrocode =
        lib.mkDefault config.hardware.enableRedistributableFirmware;

      hardware.graphics = {
        enable = true;
        extraPackages = with pkgs; [
          intel-media-driver
          libva-vdpau-driver
          libvdpau-va-gl
        ];
      };
    };
}
