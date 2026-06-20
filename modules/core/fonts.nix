{
  os = { pkgs, style, ... }: {
    fonts = {
      packages = [ (style.font.package pkgs) ];
      fontconfig.defaultFonts.monospace = [ style.font.name ];
    };
  };
}
