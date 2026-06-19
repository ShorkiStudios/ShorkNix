{
  os = { ... }: {
    environment.systemPackages = with pkgs; [ zen-browser ];
    nixpkgs.config.permittedInsecurePackages = [
      "zen-browser-unwrapped"
    ];
  };
}
