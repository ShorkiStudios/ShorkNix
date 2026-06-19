{
  description = "shork's nixos config";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "nixpkgs/nixos-25.11";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    nix-math.url = "github:xddxdd/nix-math";

    niri = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    quickshell = {
      url = "git+https://git.outfoxxed.me/quickshell/quickshell.git";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };
  };

  outputs =
    inputs:
    let
      nixosConfigurations = (import ./lib/builder.nix).outputs inputs;
      barbados = nixosConfigurations.nixosConfigurations.barbados;
      iso = barbados.config.system.build.images.iso or barbados.config.system.build.isoImage;
    in
    nixosConfigurations // {
      packages.x86_64-linux.iso = iso;
    };
}
