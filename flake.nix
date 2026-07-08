{
  description = "we-layerd — Wallpaper Engine runtime for Linux Wayland";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};

      dxc = pkgs.callPackage ./dxc.nix {};

      we-layerd = pkgs.callPackage ./we-layerd.nix {
        inherit dxc;
      };
    in
    {
      packages.${system} = {
        inherit dxc we-layerd;
        default = we-layerd;
      };

      overlays.default = final: prev: {
        dxc = final.callPackage ./dxc.nix {};
        we-layerd = final.callPackage ./we-layerd.nix {
          dxc = final.dxc;
        };
      };
    };
}
