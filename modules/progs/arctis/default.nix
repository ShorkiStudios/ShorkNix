# Arctis Nova Pro Wireless OLED daemon (barbados, restored 2026-11-01).
# Shorki's custom now-playing daemon (v3.5, built Oct 2026 on Omarchy):
# pushes MPRIS track info + album art, Barbados system stats, desktop
# notifications, and BeamNG OutGauge telemetry to the base station's
# 128x64 OLED over USB HID, rotating pages every 7.5s. Auto-reconnects
# when the base re-enumerates (v3.3+). Source: arctis_oled.py in this
# directory (project of record: ~/workspace/arctis-nova-app on Isabel's VM).
# The base's hidraw nodes are root-only by default — the udev rule below
# is the same uaccess rule from his Omarchy setup.
{
  os = { ... }: {
    # NixOS note (2026-11-02): the uaccess tag alone wasn't enough —
    # logind never stamped the session ACL on these nodes (verified:
    # udevadm showed TAGS uaccess:seat, but getfacl had no user entry
    # even after a replug), so the daemon, running as shork, couldn't
    # open them and reported "base not found". The nodes now get a
    # dedicated group instead; shork joins it in systems/barbados.nix.
    users.groups.arctis = { };
    services.udev.extraRules = ''
      KERNEL=="hidraw*", SUBSYSTEM=="hidraw", ATTRS{idVendor}=="1038", ATTRS{idProduct}=="12e0", TAG+="uaccess", GROUP="arctis", MODE="0660"
    '';
  };

  home =
    { pkgs, ... }:
    let
      python = pkgs.python3.withPackages (ps: [
        ps.pillow
        ps.dbus-python
      ]);
    in
    {
      home.file."arctis-oled.py".source = ./arctis_oled.py;

      systemd.user.services.arctis-oled = {
        Unit = {
          Description = "Arctis Nova Pro Wireless now-playing OLED daemon";
          After = [ "graphical-session.target" ];
        };
        Service = {
          Type = "simple";
          ExecStart = "${python}/bin/python3 %h/arctis-oled.py";
          Restart = "on-failure";
          RestartSec = 3;
        };
        Install = {
          WantedBy = [ "default.target" ];
        };
      };
    };
}
