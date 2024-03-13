{ config, fetchurl, lib, modulesPath, pkgs, ... }:

let
  opensbi = pkgs.callPackage ./opensbi.nix { };
  zsbl = pkgs.callPackage ./zsbl.nix { };

  # Download the vendor's Firmware Image Package
  fip = pkgs.fetchurl {
    url = "https://github.com/sophgo/bootloader-riscv/raw/64369b1ba8da02b2573e5c25639c35ba0b8f21a8/firmware/fip.bin";
    hash = "sha256-UjRNUNZm7w821CHYTy2qcUkWUa8EwOri4Gd8rbnPozI=";
  };
in
{
  imports = [
    "${modulesPath}/profiles/base.nix"
    "${modulesPath}/installer/sd-card/sd-image.nix"
  ];

  boot = {
    initrd = {
      # Some modules are missing like virtio_pci
      availableKernelModules = lib.mkForce [
        "ahci"
        "nvme"
        "radeon"
        "sd_mod"
        "sdhci_sophgo"
        "uas"
        "usb_storage"
        "xhci_pci"
      ];
      kernelModules = [
        "sdhci_sophgo"
      ];
    };
    loader = {
      grub.enable = lib.mkDefault false;
      generic-extlinux-compatible.enable = lib.mkDefault true;
    };

    supportedFilesystems = [ "ext4" "vfat" ];
  };

  sdImage = {
    imageName = "${config.sdImage.imageBaseName}-${config.system.nixos.label}-${pkgs.stdenv.hostPlatform.system}-milkv-pioneer.img";
    compressImage = false;
    # Overridden by postBuildCommands

    populateFirmwareCommands = ''
      mkdir -p firmware/riscv64

      cat >> firmware/riscv64/conf.ini <<EOF
        [sophgo-config]

        [devicetree]
        name = mango-milkv-pioneer.dtb

        [kernel]
        name = riscv64_Image

        [firmware]
        name = fw_dynamic.bin

        [ramfs]
        name = initrd.img

        [eof]
      EOF

      cp ${fip} firmware/fip.bin
      cp ${zsbl}/zsbl.bin firmware/
      cp ${opensbi}/share/opensbi/lp64/generic/firmware/fw_dynamic.bin firmware/riscv64/
      cp ${./firmware}/riscv64/initrd.img firmware/riscv64/
      cp ${./firmware}/riscv64/mango-milkv-pioneer.dtb firmware/riscv64/
      cp ${./firmware}/riscv64/riscv64_Image firmware/riscv64/

      touch firmware/BOOT
    '';

    firmwarePartitionName = "EFI";
    firmwarePartitionOffset = 1;
    firmwareSize = 256;

    populateRootCommands = ''
      mkdir -p ./files/boot
      ${config.boot.loader.generic-extlinux-compatible.populateCmd} -c ${config.system.build.toplevel} -d ./files/boot
    '';
  };
}
