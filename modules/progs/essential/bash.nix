{
  os = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [ bash ];
    home-manager.backupFileExtension = "bak";
  };

  home = { ... }: {
    programs.bash = {
      enable = true;
      shellAliases = {
        ls = "ls --color=auto";
        grep = "grep --color=auto";
      };
      initExtra = ''
        PS1='[\u@\h \W]\$ '
        export PATH="$HOME/.local/bin:$PATH"
        export QT_ICON_THEME=Papirus-Dark
        export BUN_INSTALL="$HOME/.bun"
        export PATH="$BUN_INSTALL/bin:$PATH"
      '';
    };
  };
}
