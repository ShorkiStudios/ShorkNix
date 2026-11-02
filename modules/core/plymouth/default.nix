{
  os =
    { self, pkgs, ... }:
    {
      boot.plymouth = {
        enable = true;
        themePackages = [
          (pkgs.callPackage self.package { })
        ];
        theme = "shorknix";
      };
    };
  package =
    {
      stdenv,
      unzip,
    }:
    stdenv.mkDerivation {
      pname = "shorknix-plymouth-theme";
      version = "1.0";
      src = ./theme;

      nativeBuildInputs = [
        unzip
      ];

      sourceRoot = ".";

      installPhase = ''
        ls -al
        mkdir -p $out/share/plymouth/themes
        mv theme $out/share/plymouth/themes/shorknix
        find $out/share/plymouth/themes/ -name \*.plymouth -exec sed -i "s@\/usr\/@$out\/@" {} \;
      '';
    };
}
