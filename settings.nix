{
  userSettings = {
    username = "shork";
  };

  baseStyle = {
    font = {
      size = 15;
      package = pkgs: pkgs.nerd-fonts.jetbrains-mono;
      name = "JetBrainsMono Nerd Font Propo";
    };
    border = {
      thickness = 2;
      radius = 10;
    };
    spacing = 6;
  };

  systems = {
    barbados = {
      settings = {
        system = "x86_64-linux";
        timeZone = "America/Denver";
        locale = "en_US.UTF-8";
        monitor = {
          name = "eDP-1";
          width = 1920;
          height = 1080;
          framerate = 60;
          x = 0;
          y = 0;
          scale = 1;
        };
      };
      modules =
        modules:
        (
          with modules;
          [
            systems.barbados
            core.all
            de.niri.all
          ]
          ++ (with progs; [
            essential.all
          ])
        );
    };
  };
}
