# Solaar — Logitech device manager (Barbados pairs an MX Keys Mini
# through a Logi Bolt receiver). hardware.logitech.wireless installs
# the udev rules Solaar needs and, with enableGraphical, Solaar itself.
{
  os =
    { ... }:
    {
      hardware.logitech.wireless = {
        enable = true;
        enableGraphical = true;
      };
    };
}
