{
  os =
    { pkgs, userSettings, ... }:

    {
      programs.zsh.enable = true;

      users.groups.${userSettings.username} = { };
      users.users.${userSettings.username} = {
        isNormalUser = true;
        group = userSettings.username;
        extraGroups = [
          "networkmanager"
          "wheel"
        ];
        shell = pkgs.zsh;
        initialPassword = "shork";
      };
    };
}
