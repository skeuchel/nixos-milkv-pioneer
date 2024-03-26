{ buildGoModule
, busybox
, compressFirmwareXz
, fetchFromGitHub
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

  subPackages = [ "." ];
  postBuild = ''
    mkdir -p firmware
    cp -a ${linux-firmware-xz}/lib/firmware/{amdgpu,radeon} ./firmware/

    GOROOT="$(go env GOROOT)" $GOPATH/bin/u-root \
      -build bb \
      -uinitcmd=boot \
      -files ${pkgsStatic.busybox}/bin/busybox:bin/busybox \
      -files ./firmware/:lib/firmware/ \
      -o initramfs.cpio \
      core boot
  '';

  installPhase = ''
    mkdir -p $out
    cp -ra firmware $out/firmware
    cp initramfs.cpio $out/initrd.img
  '';
}
