#!/usr/bin/env bash
set -xe

echo create an image file...
dd if=/dev/zero of=firmware.img bs=256MiB count=1

echo create partitions...
parted firmware.img mktable msdos
parted firmware.img mkpart p fat32 0% 100%
loops=$(kpartx -av firmware.img | cut -d ' ' -f 3)
fat32part=$(echo $loops | cut -d ' ' -f 1)
mkfs.vfat /dev/mapper/$fat32part -n EFI

echo mount EFI partition...
mkdir -p efi/
mount /dev/mapper/$fat32part efi
mkdir -p efi/riscv64

echo copy bootloader...
cp firmware/fip.bin efi/
cp firmware/zsbl.bin efi/
cp firmware/riscv64/riscv64_Image efi/riscv64/
cp firmware/riscv64/*.dtb efi/riscv64/
cp firmware/riscv64/initrd.img efi/riscv64/
cp firmware/riscv64/fw_dynamic.bin efi/riscv64/
cp firmware/riscv64/SG2042.fd efi/riscv64/
touch efi/BOOT

echo cleanup...
umount /dev/mapper/$fat32part
kpartx -dv firmware.img
rmdir efi

