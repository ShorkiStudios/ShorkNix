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
    home.file.".local/bin/bbs" = {
      executable = true;
      text = ''
        #!/bin/sh
        # barbados build + LIVE switch + auto-commit/push (2026-11-01) — no reboot for everyday changes
        cd "$HOME/barbados-config" || exit 1
        nix-shell -p nh --run 'nh os switch . --hostname barbados' || exit $?
        git add -A
        if git diff --cached --quiet; then
          echo "bbs: tree clean, nothing to push"
        else
          git commit -q -m "bbs: switch $(date -Iseconds)" && git push -q || echo "bbs: PUSH FAILED — commit is saved locally and will go out with the next successful push"
        fi
      '';
    };
    home.file.".local/bin/bbr" = {
      executable = true;
      text = ''
        #!/bin/sh
        # barbados build + switch + SOFT reboot + auto-commit/push (2026-11-01).
        # Soft reboot restarts all of userspace into the new generation on the
        # SAME kernel: no firmware POST, no LUKS prompt. Desktop and apps close.
        cd "$HOME/barbados-config" || exit 1
        nix-shell -p nh --run 'nh os switch . --hostname barbados' || exit $?
        git add -A
        if git diff --cached --quiet; then
          echo "bbr: tree clean, nothing to push"
        else
          git commit -q -m "bbr: switch + soft-reboot $(date -Iseconds)" && git push -q || echo "bbr: PUSH FAILED — commit is saved locally and will go out with the next successful push"
        fi
        if [ "$(readlink /run/booted-system/kernel)" != "$(readlink /run/current-system/kernel)" ]; then
          echo "bbr: KERNEL CHANGED — a soft reboot cannot load it. Full reboot instead: sudo reboot"
          exit 0
        fi
        echo "bbr: soft-rebooting in 5 seconds — desktop and all apps will close"
        sudo -v
        sleep 5
        sudo systemctl soft-reboot
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
