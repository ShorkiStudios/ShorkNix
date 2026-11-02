# Flatpak support — not present anywhere in the upstream tree.
# Barbados needs it: Unleashed Recomp (and possibly other game ports)
# ship as flatpaks.
{
  os =
    { ... }:
    {
      services.flatpak.enable = true;
    };
}
