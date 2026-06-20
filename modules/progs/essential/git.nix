{
  os = { pkgs, ... }: {
    programs.git = {
      enable = true;
      config = {
        user = {
          name = "shork";
          email = "shork@shorkstudios.com";
        };
        init.defaultBranch = "main";
      };
    };

    environment.systemPackages = with pkgs; [
      gh
    ];
  };
}
