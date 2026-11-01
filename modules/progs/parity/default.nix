# Parity module — Shorki's pre-wipe (Omarchy/Arch) package set, layered
# on top of the tt0fu tree. Purely additive: it installs what his old
# system had that the existing trees don't already provide, wires the
# NixOS options that replace Arch system packages (input method,
# keyring, gvfs, mDNS, locate, thermal, Waydroid, U2F PAM, zram, NTFS),
# and declares his flatpaks.
#
# SUGGESTED PATH: modules/progs/parity/default.nix
# Requires one settings.nix change (NOT applied by this file): add
# `parity` to the progs list of systems.barbados in settings.nix.
#
# Attr-verification rule: every attribute in the package lists below is
# a well-established nixpkgs attribute. Attributes that could not be
# confirmed for the 26.11-era unstable channel are kept OUT of the
# lists, in the "PENDING VERIFICATION" comment block at the bottom, so
# this file evaluates as-is. See mapping.md for the per-package audit.
{
  inputs = {
    nix-flatpak = {
      url = "github:gmodena/nix-flatpak";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  os =
    {
      inputs,
      pkgs,
      ...
    }:
    {
      imports = [
        inputs.nix-flatpak.nixosModules.nix-flatpak
      ];

      # --- fcitx5 (was: fcitx5 + fcitx5-gtk + fcitx5-qt) ---
      i18n.inputMethod = {
        enable = true;
        type = "fcitx5";
        fcitx5 = {
          waylandFrontend = true;
          addons = with pkgs; [
            fcitx5-gtk
            qt6Packages.fcitx5-qt # was fcitx5-qt — not a top-level attr in this nixpkgs
          ];
        };
      };

      # --- fonts (was: noto-fonts, noto-fonts-cjk, noto-fonts-emoji,
      #     woff2-font-awesome; JetBrainsMono Nerd Font already comes
      #     from settings.nix baseStyle via de/font.nix) ---
      fonts.packages = with pkgs; [
        noto-fonts
        noto-fonts-cjk-sans
        noto-fonts-cjk-serif
        noto-fonts-color-emoji
        font-awesome
      ];

      # --- system roles that Arch expressed as packages ---
      services.gnome.gnome-keyring.enable = true; # gnome-keyring
      services.gvfs.enable = true; # gvfs-mtp / gvfs-nfs / gvfs-smb (one gvfs build)
      services.avahi = {
        # nss-mdns
        enable = true;
        nssmdns4 = true;
      };
      services.opensnitch.enable = true; # opensnitch-git
      services.thermald.enable = true; # thermald (Intel laptop)
      services.locate = {
        # plocate
        enable = true;
        package = pkgs.plocate;
      };
      services.hardware.bolt.enable = true; # bolt (Thunderbolt daemon)
      security.pam.u2f.enable = true; # pam-u2f (YubiKey lock-screen unlock)
      virtualisation.waydroid.enable = true; # waydroid
      zramSwap.enable = true; # zram-generator
      boot.supportedFilesystems = [ "ntfs" ]; # ntfs-3g / ntfsprogs

      # --- flatpaks (core/flatpak.nix already sets
      #     services.flatpak.enable; nix-flatpak declares the apps) ---
      services.flatpak = {
        remotes = [
          {
            name = "flathub";
            location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
          }
        ];
        packages = [
          "org.vinegarhq.Sober"
          # io.github.hedge_dev.unleashedrecomp is deliberately NOT
          # listed here: on the old system it was a *user* install from
          # a custom remote named "unleashedrecomp1-origin" (not
          # Flathub). nix-flatpak needs that remote's flatpakrepo URL,
          # which is not in the package inventory — it can be recovered
          # from the backup's flatpak repo config during the data
          # restore phase, or the app can be installed imperatively
          # once. See decisions.md.
        ];
      };
    };

  home =
    { lib, pkgs, ... }:
    {
      # --- Discord: replace tt0fu's nixcord stack (official Discord +
      #     Vencord, and Vesktop) with Legcord — Shorki's call,
      #     2026-11-01. mkForce because upstream's discord.nix sets
      #     programs.nixcord.enable = true at default priority.
      #     Note: upstream's SUPER+D keybind still launches "discord";
      #     harmless leftover, adjust if it ever annoys.
      programs.nixcord.enable = lib.mkForce false;
      home.packages = with pkgs; [
        # --- his CLI / shell tools ---
        p7zip # 7zip (was _7zip in the draft — that attr doesn't exist in this nixpkgs; progs/3d/unity.nix pulls p7zip too, dedupes)
        alsa-utils
        bash-completion
        bat
        dua # dua-cli
        eza
        fd
        fzf
        inotify-tools
        just
        lazygit
        ripgrep
        socat
        starship # his prompt engine; de/prompt.nix keeps oh-my-posh wired — see decisions.md
        tcpdump
        tldr
        tmux
        tree-sitter # tree-sitter-cli
        whois
        zoxide

        # --- his GUI apps ---
        chromium
        tixati # added 2026-11-01 at Shorki's request — remembered mid-install:
        # the solo-dev torrent client with built-in community channels + chat.
        # NOT in his pre-wipe inventory; nixpkgs unstable carries it (unfree).
        legcord # his Discord client (Equicord rides in his restored profile);
        # also in the tree via progs/social/legcord.nix — duplicated here so
        # his layer is self-contained; home.packages dedupes it.
        evince
        foot # his terminal; de + essential keep kitty as the configured default — see decisions.md
        gajim
        gnome-disk-utility
        gnome-themes-extra
        imv # image viewer; progs/utils/feh.nix (theirs) stays too
        libreoffice # libreoffice-fresh
        mpv
        mpvScripts.mpris # was mpv-mpris — mpv scripts live under mpvScripts in this nixpkgs
        obsidian
        pinta # progs/2d/pinta.nix exists but the 2d tree is not selected for barbados
        sushi
        teams-for-linux # teams-for-linux-bin
        xournalpp # progs/studying/xournalpp.nix exists but studying is not selected for barbados
        yaru-theme # yaru-icon-theme

        # --- emulators / gaming (his, beyond progs/gaming) ---
        ares # ares-emu
        bsnes-hd
        dolphin-emu
        parsec-bin # resolves the Parsec TODO in progs/gaming/barbados-gaming-extras.nix
        prismlauncher

        # --- creation / media tools ---
        cava
        ffmpegthumbnailer
        gpu-screen-recorder # NixOS also offers programs.gpu-screen-recorder (capability wrapper) — see mapping.md
        imagemagick
        libqalculate # engine behind the Omarchy calculator (omacalc itself has no equivalent)
        vips # libvips

        # --- coding ---
        clang # progs/coding/languages/c++.nix has clang-tools + gcc, not the compiler
        luarocks
        lua5_1 # lua51
        mise # mise-bin
        neovim # his editor binary; his config was omarchy-nvim (no nixpkgs equivalent — config phase)
        python3 # not an Arch explicit package (base dep) — carries the two rows below
        python3Packages.pip # python-pip
        python3Packages.pygobject3 # python-gobject
        ruby

        # --- networking / system utilities ---
        android-tools
        bluez-tools
        cloudflared
        ddcutil
        efibootmgr
        exfatprogs
        inetutils
        inxi
        netcat-openbsd # openbsd-netcat
        pamixer
        pamtester
        qrencode
        scrcpy # scrcpy-bin
        udiskie # NOTE: core/mounting.nix also automounts via devmon — see decisions.md
        usbutils
        uwsm
        wtype
        zbar

        # --- docker CLI plugins (progs/virtualization/docker.nix
        #     enables the daemon; these may duplicate plugins bundled
        #     with pkgs.docker — harmless if so) ---
        docker-buildx
        docker-compose

        # --- printing GUI (progs/utils/printing.nix enables CUPS) ---
        cups-pk-helper
        system-config-printer

        # --- hypr* extras not in the de tree ---
        hyprland-qtutils # was hyprland-guiutils in the draft — the nixpkgs attr is hyprland-qtutils; may already ride along with pkgs.hyprland
        hyprsunset # plain package; HM also has services.hyprsunset (verify) if a service is wanted

        # --- Qt image formats (qt6-imageformats) ---
        kdePackages.qtimageformats

        # --- security / tokens ---
        yubioath-flutter # Yubico Authenticator — the yubico-authenticator attr doesn't exist in this nixpkgs; this is the same app
        yubikey-manager # ykman

        # --- misc hardware ---
        onevpl-intel-gpu # Intel oneVPL GPU runtime (was libvpl-gpu-rt — renamed in nixpkgs)
      ];
    };

  # =====================================================================
  # PENDING VERIFICATION — plausible nixpkgs attributes that could not
  # be confirmed from here for the 26.11-era unstable channel. They are
  # commented out so this file evaluates as-is. Verify each with
  # `nix eval nixpkgs#<attr>.name` (or search.nixos.org) on Barbados,
  # then move the confirmed ones into home.packages above:
  #
  #   beammp-launcher            # beammp (BeamMP launcher)
  #   dotnetCorePackages.runtime_10_0
  #                              # dotnet-runtime (he had .NET 10;
  #                              #  progs/3d already pulls the .NET 8 SDK)
  #   handy                      # handy (offline speech-to-text app)
  #   hyprland-preview-share-picker
  #   llvm                       # llvm (pkgs.llvm vs llvmPackages.llvm)
  #   nautilus-python
  #   tzupdate
  #   unixbench
  #   usage                      # usage (jdx's CLI-spec tool)
  #   # fonts: iA Writer fonts (ttf-ia-writer) — attribute name
  #   # unknown; candidates like ia-writer-duo need checking.
  # =====================================================================
}
