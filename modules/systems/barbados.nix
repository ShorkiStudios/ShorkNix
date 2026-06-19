{
  os =
    {
      config,
      lib,
      modulesPath,
      ...
    }:
    {
      imports = [
        (modulesPath + "/installer/scan/not-detected.nix")
      ];

      boot = {
        kernelModules = [
          "kvm-intel"
        ];
        initrd = {
          availableKernelModules = [
            "nvme"
            "xhci_pci"
            "ahci"
            "usb_storage"
            "sd_mod"
          ];
          kernelModules = [ ];
          services.lvm.enable = true;
        };
        extraModulePackages = [ ];

        initrd.luks.devices = {
          cryptroot = {
            device = "/dev/disk/by-label/CRYPTROOT";
            preLVM = true;
          };
        };
      };

      fileSystems."/" = {
        device = "/dev/disk/by-label/NIXROOT";
        fsType = "btrfs";
        options = [
          "subvol=@"
          "compress=zstd:3"
          "ssd"
          "space_cache=v2"
        ];
      };

      fileSystems."/boot" = {
        device = "/dev/disk/by-label/NIXBOOT";
        fsType = "vfat";
        options = [
          "fmask=0077"
          "dmask=0077"
        ];
      };

      fileSystems."/home" = {
        device = "/dev/disk/by-label/NIXROOT";
        fsType = "btrfs";
        options = [
          "subvol=@home"
          "compress=zstd:3"
          "ssd"
          "space_cache=v2"
        ];
      };

      fileSystems."/nix" = {
        device = "/dev/disk/by-label/NIXROOT";
        fsType = "btrfs";
        options = [
          "subvol=@nix"
          "noatime"
          "compress=zstd:3"
          "ssd"
          "space_cache=v2"
        ];
      };

      swapDevices = [
        { device = "/dev/disk/by-label/NIXSWAP"; }
      ];

      nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
      hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    };
}
