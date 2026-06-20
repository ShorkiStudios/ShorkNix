{
  os = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      (element-desktop.override { commandLineArgs = [ "--password-store=gnome-libsecret" ]; })
      gajim
    ];
  };
}
