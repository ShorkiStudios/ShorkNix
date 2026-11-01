{
  home =
    { ... }:
    {
      programs.git = {
        enable = true;
        lfs.enable = true;
        settings.user = {
          name = "Shorki";
          email = "shorkicalypso@gmail.com";
        };
      };
    };
}
