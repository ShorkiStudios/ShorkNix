# Flatpak support — not present anywhere in upstream tt0fu's tree.
# Barbados needs it: Unleashed Recomp (and possibly other game ports)
# ship as flatpaks.
{
  os =
    { ... }:
    {
      services.flatpak.enable = true;
    };
}
