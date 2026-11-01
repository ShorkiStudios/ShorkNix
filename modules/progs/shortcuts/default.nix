# Shorki's personal shortcuts (barbados, 2026-11-01).
# `bb` = the standard Barbados build command, so he never has to paste the long form.
{
  home = { ... }: {
    home.sessionPath = [ "$HOME/.local/bin" ];
    home.file.".local/bin/bb" = {
      executable = true;
      text = ''
        #!/bin/sh
        # barbados build — short form of the nh os build command
        cd "$HOME/barbados-config" && exec nix-shell -p nh --run 'nh os build . --hostname barbados'
      '';
    };
    home.file.".local/bin/bbt" = {
      executable = true;
      text = ''
        #!/bin/sh
        # barbados boot — short form of the nh os boot command (stage for next boot; reboot separately)
        cd "$HOME/barbados-config" && exec nix-shell -p nh --run 'nh os boot . --hostname barbados'
      '';
    };
  };
}
