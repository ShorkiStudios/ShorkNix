# Spotify — no module upstream. Barbados runs the nixpkgs
# build with a desktop entry that carries the flags the old Omarchy
# install needed:
#   --disable-gpu          (GPU process crashes/glitches otherwise)
#   --ozone-platform=wayland (added on Omarchy 2026-10-28)
{
  home =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.spotify ];

      xdg.desktopEntries.spotify = {
        name = "Spotify";
        genericName = "Music Player";
        exec = "spotify --disable-gpu --ozone-platform=wayland %U";
        icon = "spotify-client";
        categories = [
          "Audio"
          "Music"
          "Player"
          "AudioVideo"
        ];
        mimeType = [ "x-scheme-handler/spotify" ];
      };
    };
}
