{ buildLinux, fetchFromGitHub, kernelPatches, lib, ... } @ args:

let
  modDirVersion = "6.8.0";
in
buildLinux (args // {
  inherit kernelPatches modDirVersion;
  version = "${modDirVersion}-milkv-pioneer";
  src = fetchFromGitHub {
    owner = "milkv-community";
    repo = "linux";
    rev = "2b5cf66a7b62dcbe442f6cc738aeb7402e71fd71";
    hash = "sha256-IYxnyotoN6uKYjI0+ELbi/thSFitGsC/EyYbD3K7K/E=";
  };

  defconfig = "sophgo_mango_normal_defconfig";
  structuredExtraConfig = let inherit (lib.kernel) freeform module yes; in {
    # LinuxBoot will override the console bootparams which will result
    # in the distro kernel to be booted with e.g. console=tty1 only.
    # https://github.com/sophgo/bootloader-riscv/issues/71
    # Force output on serial console through the config. This is also
    # needed to get the forced serial-getty to be started.
    # We also list tty1 again because according to
    # https://docs.kernel.org/admin-guide/serial-console.html and
    # https://0pointer.de/blog/projects/serial-console.html
    # this will be the main console.
    CMDLINE = freeform "console=ttyS0,115200 console=tty1";
    CMDLINE_EXTEND = yes;

    # Enable these explicitly because they are not enabled by the defconfig.
    # The all-hardware profile expects these to be built.
    VIRTIO_MENU = yes;
    VIRTIO_PCI = module;

    # There is an i2c mcu driver (drivers/soc/sophgo/umcu) which is always
    # compiled into the kernel. Hence some of the i2c support also needs to
    # be compiled in instead of being compiled as a module.
    I2C = yes;
    I2C_CHARDEV = yes;
    I2C_DESIGNWARE_PLATFORM = yes;
  };

} // (args.argsOverride or { }))
