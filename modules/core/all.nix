{
  deps =
    modules: with modules.core; [
      bootloader
      bluetooth
      networking
      nix
      sound
      time
      user
    ];
}
