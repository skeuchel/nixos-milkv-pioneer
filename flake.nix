{
  inputs = {
    nixos-hardware.url = "github:skeuchel/nixos-hardware/milkv-pioneer";
    nixpkgs.url = "github:nixos/nixpkgs/master";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    { nixpkgs
    , nixos-hardware
    , flake-utils
    , ...
    }:
    flake-utils.lib.eachDefaultSystem (system:
    let
      pkgs = import nixpkgs {
        localSystem.system = system;
        crossSystem.system = "riscv64-linux";
      };
    in
    rec {
      packages.default = packages.sd-image;
      packages.opensbi = pkgs.callPackage ./opensbi.nix { };
      packages.linuxboot-kernel = pkgs.callPackage ./linuxboot-kernel.nix { };
      packages.linuxboot-u-root = pkgs.callPackage ./linuxboot-u-root.nix { };
      packages.zsbl = pkgs.callPackage ./zsbl.nix { };
      packages.sd-image =
        (import "${nixpkgs}/nixos" {
          configuration = {
            imports = [
              "${nixos-hardware}/milkv/pioneer"
              ./sd-image.nix
            ];

            nixpkgs.crossSystem = {
              config = "riscv64-unknown-linux-gnu";
              system = "riscv64-linux";
            };

            system.stateVersion = "23.11";
          };
          inherit system;
        }).config.system.build.sdImage;
    });
}
