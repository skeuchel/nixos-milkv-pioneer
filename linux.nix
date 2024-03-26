{ buildLinux
, fetchFromGitHub
, kernelPatches
, lib
, ...
} @ args:
let
  modDirVersion = "6.6.20";
in
buildLinux (args
  // {
  version = "${modDirVersion}-milkv-pioneer";
  inherit kernelPatches modDirVersion;

  src = fetchFromGitHub {
    owner = "sophgo";
    repo = "linux-riscv";
    rev = "caa949e3690fe8a4656313b2b56f52666fa880db";
    hash = "sha256-qJpR3KMgvP4tfPfBfQ/MiEWg/uuuxHYuACK8taKKK3E=";
  };

  defconfig = "sophgo_mango_normal_defconfig";
  structuredExtraConfig = with lib.kernel; {
    # Force output on serial console
    # https://github.com/sophgo/bootloader-riscv/issues/71
    #CMDLINE = freeform "console=ttyS0,115200";
    #CMDLINE_EXTEND = yes;
    VIRTIO_MENU = yes;
    VIRTIO_PCI = module;

    # There is an i2c mcu driver (drivers/soc/sophgo/umcu) which is always
    # compiled into the kernel. Hence some of the i2c support also needs to
    # be compiled in instead of being compiled as a module.
    I2C = yes;
    I2C_CHARDEV = yes;
    I2C_DESIGNWARE_PLATFORM = yes;
  };

  extraMeta.branch = "sg2042-dev-6.6";
}
  // (args.argsOverride or { }))
