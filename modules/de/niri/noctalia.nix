{
  os = { pkgs, ... }: {
    environment.systemPackages = with pkgs; [
      quickshell
    ];
  };
}
