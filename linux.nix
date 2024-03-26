{ buildLinux
, fetchFromGitHub
, kernelPatches
, lib
, ...
} @ args:
let
  modDirVersion = "6.8.0";
in
buildLinux (args
  // {
  version = "${modDirVersion}-milkv-pioneer";
  inherit kernelPatches modDirVersion;

  src = fetchFromGitHub {
    owner = "milkv-community";
    repo = "linux";
    rev = "dfe9dcc4b86297e415d9ffd67fbf1194df9e1ff8";
    hash = "sha256-zCrQwjFn09gyal511xLCxVP2+Uvlp1gsVta42PL8+zQ=";
  };

  defconfig = "sophgo_mango_normal_defconfig";
  structuredExtraConfig = with lib.kernel; {
    # Force output on serial console
    # https://github.com/sophgo/bootloader-riscv/issues/71
    #CMDLINE = freeform "console=ttyS0,115200";
    #CMDLINE_EXTEND = yes;

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
