{
  os =
    { systemSettings, ... }:

    {
      time.timeZone = systemSettings.timeZone;
      i18n.defaultLocale = systemSettings.locale;
      console.keyMap = "us";
    };
}
