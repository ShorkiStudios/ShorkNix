# Tailscale — not an upstream module (the base ships wireguard only).
# Barbados uses Tailscale for the Muse PC Bridge's Funnel door.
{
  os =
    { ... }:
    {
      services.tailscale.enable = true;
    };
}
