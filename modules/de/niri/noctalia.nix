{
  os = { ... }: {
    environment.systemPackages = with pkgs; [
      quickshell
    ];
  };
}
