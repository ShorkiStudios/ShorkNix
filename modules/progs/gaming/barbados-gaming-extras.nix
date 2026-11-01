# Barbados gaming extras that are NOT declaratively wired yet.
# This module is intentionally empty — it exists to hold the TODOs in
# the tree where they belong. Do not delete it until every item below
# is either implemented or consciously dropped.
#
# TODO (Parsec): Shorki uses Parsec to remote into a friend's Arizona
#   PC for PCVR. No module added: the nixpkgs Parsec package situation
#   and its login/session persistence need checking on the real system
#   first. Decide then whether it becomes a package here, a flatpak,
#   or a manual install.
#
# TODO (Resonite): installed through Steam (see steam.nix) — the app
#   itself needs no module. What DOES need doing post-install is the
#   data restore: the headless/world data and the
#   ~/Resonite/start-headless.sh setup from the Omarchy backup get
#   restored by hand, and any launch flags / Proton version pinning
#   get recorded here once confirmed working.
#
# TODO (game recomp ports + Alchemy viewer): ProjectCane, Dusklight
#   (AppImage), the Metroid Prime port, Unleashed Recompiled and the
#   Alchemy viewer are plain files/binaries restored from backup, not
#   nix packages. programs.nix-ld is already enabled in
#   modules/progs/utils/nix-ld.nix, which is what makes those foreign
#   binaries runnable. If any port needs extra libraries, extend the
#   nix-ld library list there.
{
  home = { ... }: { };
}
