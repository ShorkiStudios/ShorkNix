{
  os = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [ alacritty ];
  };

  home = { style, ... }: {
    programs.alacritty = {
      enable = true;
      settings = {
        font = {
          size = style.font.size;
          normal = {
            family = style.font.name;
            style = "Regular";
          };
          bold = {
            family = style.font.name;
            style = "Bold";
          };
          italic = {
            family = style.font.name;
            style = "Italic";
          };
        };
      };
    };
  };
}
