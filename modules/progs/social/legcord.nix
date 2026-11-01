# Legcord — Shorki's Discord client (with Equicord), instead of
# upstream's nixcord/vesktop setup in discord.nix.
#
# TODO: Equicord. Legcord is in nixpkgs as a plain package, but the
# Equicord integration Shorki uses (Legcord + Equicord plugins) is not
# declaratively configured here. After install, verify whether the
# restored Legcord profile from the Omarchy backup brings Equicord
# along; if not, wire Equicord in explicitly.
{
  home =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.legcord ];
    };
}
