# Shorki's personal shortcuts (barbados, 2026-11-01).
# `bb` = the standard Barbados build command, so he never has to paste the long form.
{
  home = { ... }: {
    home.sessionPath = [ "$HOME/.local/bin" ];
    home.file.".local/bin/bb" = {
      executable = true;
      text = ''
        #!/bin/sh
        # barbados build + auto-commit/push (auto-push added 2026-11-01 at Shorki's request)
        cd "$HOME/barbados-config" || exit 1
        nix-shell -p nh --run 'nh os build . --hostname barbados' || exit $?
        # Build succeeded: sweep any changes (normally just the result
        # symlink, which Shorki wants tracked), commit, and push.
        git add -A
        if git diff --cached --quiet; then
          echo "bb: tree clean, nothing to push"
        else
          git commit -q -m "bb: build $(date -Iseconds)" && git push -q || echo "bb: PUSH FAILED — commit is saved locally and will go out with the next successful push"
        fi
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
