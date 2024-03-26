{ fetchFromGitHub
, lib
, linuxManualConfig
, stdenv
, ...
}:

linuxManualConfig rec {
  inherit lib stdenv;
  # src = fetchFromGitHub {
  #   owner = "sophgo";
  #   repo = "linux-riscv";
  #   rev = "caa949e3690fe8a4656313b2b56f52666fa880db";
  #   hash = "sha256-qJpR3KMgvP4tfPfBfQ/MiEWg/uuuxHYuACK8taKKK3E=";
  # };
  # version = "${modDirVersion}-milkv-pioneer";
  # modDirVersion = "6.6.20";
  # configfile = "${src}/arch/riscv/configs/sophgo_mango_normal_defconfig";
  # extraMeta.branch = "sg2042-dev-6.6";

  src = fetchFromGitHub {
    owner = "milkv-community";
    repo = "linux";
    rev = "dfe9dcc4b86297e415d9ffd67fbf1194df9e1ff8";
    hash = "sha256-zCrQwjFn09gyal511xLCxVP2+Uvlp1gsVta42PL8+zQ=";
  };
  version = "${modDirVersion}-milkv-pioneer";
  modDirVersion = "6.8.0";
  configfile = "${src}/arch/riscv/configs/sophgo_mango_normal_defconfig";
}
