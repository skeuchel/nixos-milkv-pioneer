{ buildGoModule
, busybox
, compressFirmwareXz
, fetchFromGitHub
, fetchpatch
, lib
, linux-firmware
, pkgsStatic
, ...
}:

# Based on
# https://github.com/sophgo/bootloader-riscv/blob/e0839852d571df106db622611f4786ae17e8df0f/scripts/envsetup.sh#L809-L819

let
  linux-firmware-xz = compressFirmwareXz linux-firmware;
in

buildGoModule rec {
  pname = "u-root";
  version = "0.14.0";
  src = fetchFromGitHub {
    owner = "u-root";
    repo = "u-root";
    rev = "v${version}";
    hash = "sha256-8zA3pHf45MdUcq/MA/mf0KCTxB1viHieU/oigYwIPgo=";
  };
  vendorHash = null;
  patches = [
    (
      fetchpatch {
        url = "https://github.com/sophgo/bootloader-riscv/commit/322c3305763872a9b88a1c85d79bca63b8fbe7a6.patch";
        hash = "sha256-l5r3DbcMqRYD5FhRBqtEIEscZAdDvjmQJE4BIAtWYWE=";
        stripLen = 1;
      }
    )
  ];

  subPackages = [ "." ];
  postBuild = ''
    # Include firmware for AMD GPUs based on the vendor's list here:
    # https://github.com/sophgo/bootloader-riscv/tree/47771f786e8239f681cc4fdadb7a9a2e22688f93/u-root/firmware
    mkdir -p firmware/{amdgpu,radeon}
    cp -aL ${linux-firmware-xz}/lib/firmware/amdgpu/polaris12*.bin.xz firmware/amdgpu/
    cp -aL ${linux-firmware-xz}/lib/firmware/radeon/{BTC,CAICOS,SUMO}_*.bin.xz firmware/radeon/
    cp -aL ${linux-firmware-xz}/lib/firmware/radeon/{TAHITI,tahiti}_*.bin.xz firmware/radeon/

    GOROOT="$(go env GOROOT)" $GOPATH/bin/u-root \
      -build bb \
      -uinitcmd=boot \
      -files ./firmware/:lib/firmware/ \
      -o initramfs.cpio \
      core boot
  '';

  installPhase = ''
    cp -a firmware $out/
    install -D initramfs.cpio $out/initrd.img
  '';
}
