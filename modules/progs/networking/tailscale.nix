# Tailscale — not a tt0fu module upstream (he ships wireguard only).
# Barbados uses Tailscale for the Muse PC Bridge's Funnel door.
{
  os =
    { ... }:
    {
      services.tailscale.enable = true;
    };
}
