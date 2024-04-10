{ fetchFromGitHub, lib, linuxManualConfig, stdenv, ... }:

linuxManualConfig rec {
  inherit lib stdenv;
  modDirVersion = "6.8.0";
  version = "${modDirVersion}-milkv-pioneer";
  src = fetchFromGitHub {
    owner = "milkv-community";
    repo = "linux";
    rev = "2b5cf66a7b62dcbe442f6cc738aeb7402e71fd71";
    hash = "sha256-IYxnyotoN6uKYjI0+ELbi/thSFitGsC/EyYbD3K7K/E=";
  };
  configfile = "${src}/arch/riscv/configs/sophgo_mango_normal_defconfig";
}
