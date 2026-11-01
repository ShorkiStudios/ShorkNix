{
  home =
    { inputs, allModules, ... }:
    {
      programs.fastfetch = {
        enable = true;
        settings = {
          logo = {
            source = "${./logo.txt}";
            type = "file";
            color =
              let
                # Pansexual flag colors (Barbados, 2026-11-01) — was a
                # generated rainbow from the shared color lib. The
                # logo's six slots are the snowflake's six arms, so the
                # three flag colors repeat twice, opposite arms matching.
                palette = [
                  "#FF218C"
                  "#FFD800"
                  "#21B1FF"
                  "#FF218C"
                  "#FFD800"
                  "#21B1FF"
                ];
              in
              builtins.listToAttrs (
                builtins.genList (i: {
                  name = toString (i + 1);
                  value = builtins.elemAt palette i;
                }) 6
              );
          };
          modules = [
            "title"
            "separator"
            "os"
            "host"
            "kernel"
            "uptime"
            "packages"
            "shell"
            "display"
            "de"
            "wm"
            "terminal"
            "cpu"
            "gpu"
            "memory"
            "disk"
            "break"
            "colors"
          ];
        };
      };
      programs.bash.bashrcExtra = "fastfetch";
    };
}
