{ config, lib, modulesPath, pkgs, ... }:

let
  opensbi = pkgs.callPackage ./opensbi.nix { };
  zsbl = pkgs.callPackage ./zsbl.nix { };
  kernel = pkgs.callPackage ./linuxboot-kernel.nix { };
  dtbs = config.hardware.deviceTree.package;
  initrd = pkgs.callPackage ./linuxboot-initrd.nix { };

  # Download the vendor's Firmware Image Package
  fip = pkgs.fetchurl {
    url = "https://github.com/sophgo/bootloader-riscv/raw/3f750677e0249ff549ad3fe20bbc800998503539/firmware/fip.bin";
    hash = "sha256-rav00Ok6+FU77lI0piQPHCaz7Tw1RSbyUal4PyeSccg=";
  };
  conf-ini = pkgs.writeText "conf.ini" ''
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
  '';
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
        "mmc_block"
        "nvme"
        "r8169"
        "sd_mod"
        "sdhci_pci"
        "sdhci_sophgo"
        "uas"
        "usb_storage"
        "xhci_hcd"
        "xhci_pci"
      ];
      kernelModules = [
        "mmc_block"
        "sdhci_pci"
        "sdhci_sophgo"
        "xhci_hcd"
        "xhci_pci"
      ];
    };
    kernelPackages = pkgs.linuxPackagesFor (pkgs.callPackage ./linux.nix {
      inherit (config.boot) kernelPatches;
    });
    kernelParams = [
      "earlycon"
      "console=ttyS0,115200"
    ];

    loader = {
      grub.enable = lib.mkDefault false;
      generic-extlinux-compatible.enable = lib.mkDefault true;
    };

    supportedFilesystems = [ "ext4" "vfat" ];
  };

  hardware.deviceTree = {
    enable = true;
    name = "sophgo/mango-milkv-pioneer.dtb";
    overlays = [{
      name = "serial-output-patch";
      dtsFile = ./serial-output-patch.dts;
    }];
  };

  sdImage = {
    imageName = "${config.sdImage.imageBaseName}-${config.system.nixos.label}-${pkgs.stdenv.hostPlatform.system}-milkv-pioneer.img";
    compressImage = false;
    # Overridden by postBuildCommands

    populateFirmwareCommands = ''
      mkdir -p firmware/riscv64

      cp ${conf-ini} firmware/riscv64/conf.ini
      cp ${fip} firmware/fip.bin
      cp ${zsbl}/zsbl.bin firmware/
      cp ${opensbi}/share/opensbi/lp64/generic/firmware/fw_dynamic.bin firmware/riscv64/
      cp ${initrd}/initrd.img firmware/riscv64/
      cp ${dtbs}/dtbs/sophgo/mango-milkv-pioneer.dtb firmware/riscv64/
      cp ${kernel}/Image firmware/riscv64/riscv64_Image

      touch firmware/BOOT
    '';

    firmwarePartitionOffset = 1;
    firmwareSize = 128;

    populateRootCommands = ''
      mkdir -p ./files/boot
      ${config.boot.loader.generic-extlinux-compatible.populateCmd} -c ${config.system.build.toplevel} -d ./files/boot
    '';
  };
}
