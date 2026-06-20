{
  deps =
    modules: with modules.core; [
      bootloader
      bluetooth
      modules.core."conservation-mode"
      fonts
      networking
      nix
      plymouth
      sound
      state-version
      time
      user
    ];
}
