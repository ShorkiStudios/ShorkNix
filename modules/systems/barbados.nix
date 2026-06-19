{
  os =
    {
      config,
      lib,
      pkgs,
      modulesPath,
      inputs,
      ...
    }:
    {
      imports = [
        (modulesPath + "/installer/scan/not-detected.nix")
      ];

      boot = {
        kernelModules = [
          "kvm-intel"
          "xe"
          "snd_hda_intel"
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
        };
        extraModulePackages = [ ];

        loader = {
          systemd-boot.enable = true;
          efi.canTouchEfiVariables = true;
        };

        initrd.luks.devices = {
          cryptroot = {
            device = "/dev/disk/by-partuuid/f62a8ce8-98e3-4d07-83c0-0d0b0b9a1fc6";
            preLVM = true;
          };
        };
      };

      fileSystems."/" = {
        device = "/dev/disk/by-uuid/42284ccd-7f4a-4f2b-b462-154fadc27540";
        fsType = "btrfs";
        options = [
          "subvol=@"
          "compress=zstd:3"
          "ssd"
          "space_cache=v2"
        ];
      };

      fileSystems."/boot" = {
        device = "/dev/disk/by-uuid/AFB7-9CEA";
        fsType = "vfat";
        options = [
          "fmask=0077"
          "dmask=0077"
        ];
      };

      fileSystems."/home" = {
        device = "/dev/disk/by-uuid/42284ccd-7f4a-4f2b-b462-154fadc27540";
        fsType = "btrfs";
        options = [
          "subvol=@home"
          "compress=zstd:3"
          "ssd"
          "space_cache=v2"
        ];
      };

      fileSystems."/nix" = {
        device = "/dev/disk/by-uuid/42284ccd-7f4a-4f2b-b462-154fadc27540";
        fsType = "btrfs";
        options = [
          "subvol=@nix"
          "noatime"
          "compress=zstd:3"
          "ssd"
          "space_cache=v2"
        ];
      };

      swapDevices = [ ];

      nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
      hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

      hardware.graphics = {
        enable = true;
        extraPackages = with pkgs; [
          intel-media-driver
          intel-compute-runtime
          vaapiIntel
        ];
      };
    };
}
