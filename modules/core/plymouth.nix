{
  os = { config, lib, pkgs, ... }:

  let
    wallpaperFile = /home/shork/Pictures/Wallpapers/wallhaven_gp8l2e.jpg;

    wallpaperTheme = pkgs.stdenvNoCC.mkDerivation {
      name = "wallhaven-plymouth-theme";
      src = wallpaperFile;

      dontUnpack = true;

      nativeBuildInputs = with pkgs; [ imagemagick ];

      installPhase = ''
        runHook preInstall

        mkdir -p $out/share/plymouth/themes/wallhaven

        convert "$src" -resize 1920x1080^ -gravity center -extent 1920x1080 \
          $out/share/plymouth/themes/wallhaven/wallpaper.png

        convert -size 16x16 xc:none -fill '#c0caf5' -draw "circle 8,8 8,3" \
          $out/share/plymouth/themes/wallhaven/bullet.png

        convert -size 344x42 xc:none -fill 'rgba(25,30,46,0.92)' \
          -stroke 'rgba(255,255,255,0.10)' -strokewidth 2 \
          -draw "roundrectangle 1,1 342,40 12,12" \
          $out/share/plymouth/themes/wallhaven/entry.png

        convert -size 520x186 xc:none -fill 'rgba(10,12,22,0.55)' \
          -stroke 'rgba(255,255,255,0.08)' -strokewidth 2 \
          -draw "roundrectangle 1,1 518,184 24,24" \
          $out/share/plymouth/themes/wallhaven/card.png

        convert -size 32x32 xc:none -fill '#c0caf5' \
          -draw "roundrectangle 4,6 28,28 4,4" \
          -draw "circle 16,16 16,10" \
          -draw "rectangle 12,20 20,22" \
          $out/share/plymouth/themes/wallhaven/lock.png

        cat > $out/share/plymouth/themes/wallhaven/wallhaven.plymouth << PLYMOUTHEOF
[Plymouth Theme]
Name=Wallhaven
Description=Custom wallpaper boot splash
ModuleName=script

[script]
ImageDir=$out/share/plymouth/themes/wallhaven
ScriptFile=$out/share/plymouth/themes/wallhaven/wallhaven.script
PLYMOUTHEOF

        cat > $out/share/plymouth/themes/wallhaven/wallhaven.script << 'SCRIPTEOF'
Wallpaper.SetBackgroundTopColor(0.02, 0.02, 0.03);
Wallpaper.SetBackgroundBottomColor(0.02, 0.02, 0.03);

img = Image("wallpaper.png");
screen_ratio = Window.GetHeight() / Window.GetWidth();
img_ratio = img.GetHeight() / img.GetWidth();

if (screen_ratio > img_ratio) {
  scale = Window.GetHeight() / img.GetHeight();
} else {
  scale = Window.GetWidth() / img.GetWidth();
}

scaled = img.Scale(img.GetWidth() * scale, img.GetHeight() * scale);
bg = Sprite(scaled);
bg.SetPosition(
  Window.GetWidth() / 2 - scaled.GetWidth() / 2,
  Window.GetHeight() / 2 - scaled.GetHeight() / 2,
  -100
);

pass_bullet = Image("bullet.png");
pass_entry = Image("entry.png");
pass_lock = Image("lock.png");

card = Image("card.png");
card_sprite = Sprite(card);

pass_lock_sprite = Sprite();
pass_prompt_sprite = Sprite();
pass_entry_sprite = Sprite();

global.password_shown = 0;
global.password_bullets = 0;

fun display_password_callback(prompt, bullets) {
  global.password_shown = 1;
  global.password_bullets = bullets;

  cx = Window.GetWidth() / 2;
  cy = Window.GetHeight() / 2;
  card_x = cx - card.GetWidth() / 2;
  card_y = cy - card.GetHeight() / 2;

  card_sprite.SetPosition(card_x, card_y, 50);

  pass_lock_sprite.SetImage(pass_lock);
  pass_lock_sprite.SetPosition(cx - pass_lock.GetWidth() / 2, card_y + 22, 100);

  prompt_image = Image.Text("Unlock", 1, 1, 1);
  pass_prompt_sprite.SetImage(prompt_image);
  pass_prompt_sprite.SetPosition(cx - prompt_image.GetWidth() / 2, card_y + 62, 100);

  pass_entry_sprite.SetImage(pass_entry);
  pass_entry_sprite.SetPosition(cx - pass_entry.GetWidth() / 2, card_y + 102, 100);

  bullet_gap = 6;
  total_bullet_width = bullets * pass_bullet.GetWidth();
  if (bullets > 1)
    total_bullet_width = total_bullet_width + (bullets - 1) * bullet_gap;

  bullet_x = cx - total_bullet_width / 2;
  bullet_y = card_y + 113;

  password_bullets = null;
  for (i = 0; i < bullets; i++) {
    password_bullets[i] = Sprite(pass_bullet);
    password_bullets[i].SetPosition(bullet_x + i * (pass_bullet.GetWidth() + bullet_gap), bullet_y, 110);
  }
}

fun display_normal_callback() {
  global.password_shown = 0;
}

Plymouth.SetDisplayPasswordFunction(display_password_callback);
Plymouth.SetDisplayNormalFunction(display_normal_callback);
SCRIPTEOF

        runHook postInstall
      '';
    };
  in
  {
    boot = {
      plymouth = {
        enable = true;
        theme = "wallhaven";
        themePackages = [ wallpaperTheme ];
      };

      kernelParams = [
        "quiet"
        "splash"
        "loglevel=3"
        "udev.log_priority=3"
      ];

      initrd.systemd.enable = true;
      consoleLogLevel = 3;
      initrd.verbose = false;
    };
  };
}
