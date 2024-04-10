{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/master";
  };

  outputs = { nixpkgs, ... }:
    let
      nixos-hardware = ./.;
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
        "riscv64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      forAllSupportedSystems = nixpkgs.lib.genAttrs supportedSystems;
    in
    {
      packages = forAllSupportedSystems (system:
        let
          pkgs = import nixpkgs {
            localSystem.system = system;
            crossSystem.system = "riscv64-linux";
          };
        in
        rec {
          default = sd-image;
          opensbi = pkgs.callPackage "${nixos-hardware}/milkv/pioneer/opensbi.nix" { };
          linuxboot-kernel = pkgs.callPackage "${nixos-hardware}/milkv/pioneer/linuxboot-kernel.nix" { };
          linuxboot-initrd = pkgs.callPackage "${nixos-hardware}/milkv/pioneer/linuxboot-initrd.nix" { };
          zsbl = pkgs.callPackage "${nixos-hardware}/milkv/pioneer/zsbl.nix" { };
          sd-image = (import "${nixpkgs}/nixos" {
            configuration = {
              imports = [
                "${nixos-hardware}/milkv/pioneer/sd-image-installer.nix"
              ];

              nixpkgs.buildPlatform.system = system;
              nixpkgs.hostPlatform.system = "riscv64-linux";

              hardware.deviceTree.overlays = [{
                name = "linuxboot-serial-output";
                dtsFile = ./linuxboot-serial-output.dts;
              }];

              sdImage.compressImage = false;

              system.stateVersion = "24.05";
            };
            inherit system;
          }).config.system.build.sdImage;
        });
    };
}
