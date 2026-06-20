{
  os = { pkgs, systemSettings, ... }:
  let
    wallpaperFile = /home/shork/Pictures/Wallpapers/wallhaven_gp8l2e.jpg;
  in
  {
    boot.loader = {
      grub = {
        enable = true;
        device = "nodev";
        efiSupport = true;
        configurationLimit = 5;
        theme = pkgs.minimal-grub-theme;
        backgroundColor = "#000000";
        splashImage = wallpaperFile;
        gfxmodeEfi = "${toString systemSettings.monitor.width}x${toString systemSettings.monitor.height}, auto";
        gfxpayloadEfi = "keep";
        extraEntries = ''
          menuentry "Systemd-boot fallback" {
            search --no-floppy --file --set=root /EFI/systemd/systemd-bootx64.efi
            chainloader /EFI/systemd/systemd-bootx64.efi
          }
        '';
      };

      efi.canTouchEfiVariables = true;
    };
  };
}
