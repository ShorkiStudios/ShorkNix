# Muse PC tunnel (barbados, 2026-11-01): runs the Cloudflare "muse-pc"
# tunnel as a boot service so Isabel's SSH (nix.shorknet.dev) survives
# reboots without Shorki launching cloudflared by hand. The tunnel token
# lives OUTSIDE the repo and the Nix store, in
# /home/shork/.config/cloudflared/muse-pc.token (mode 600, written by
# Shorki himself from his shell history); the service only reads it via
# --token-file. NOTE: the tunnel token was pasted in chat on 2026-11-01 —
# rotate it from the Cloudflare dashboard when convenient.
{
  os =
    { pkgs, ... }:
    {
      systemd.services.cloudflared-muse = {
        description = "Cloudflare tunnel muse-pc (Isabel SSH access to Barbados)";
        after = [ "network-online.target" ];
        wants = [ "network-online.target" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          ExecStart = "${pkgs.cloudflared}/bin/cloudflared tunnel --protocol http2 run --token-file /home/shork/.config/cloudflared/muse-pc.token";
          Restart = "on-failure";
          RestartSec = "5s";
        };
      };
    };
}
