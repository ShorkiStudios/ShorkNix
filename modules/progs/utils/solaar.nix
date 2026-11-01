# Solaar — Logitech device manager (Barbados pairs an MX Keys Mini
# through a Logi Bolt receiver). hardware.logitech.wireless installs
# the udev rules Solaar needs; the Solaar app itself is enabled via
# programs.solaar (nixpkgs renamed hardware.logitech.wireless's
# enableGraphical to programs.solaar.enable — updated 2026-11-01,
# which also silences the rename evaluation warning).
{
  os =
    { ... }:
    {
      hardware.logitech.wireless.enable = true;
      programs.solaar.enable = true;
    };
}
