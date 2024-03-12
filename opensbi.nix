{ fetchFromGitHub
, opensbi
}:

opensbi.overrideAttrs (attrs: {
  version = "1.2-git-3745939";

  src = fetchFromGitHub {
    owner = "sophgo";
    repo = "opensbi";
    rev = "3745939ceb8ba71f45c4cfad205912cedbc76bd9";
    hash = "sha256-UXsAKXO0fBjHkkanZlB0led9CiVeqa01dTM4r7D9dzs=";
  };

  makeFlags =
    # Based on the vendor options
    # https://github.com/sophgo/bootloader-riscv/blob/01dc52ce10e7cf489c93e4f24b6bfe1bf6e55919/scripts/envsetup.sh#L299
    attrs.makeFlags ++ [
      "PLATFORM=generic"
      "FW_PIC=y"
      "BUILD_INFO=y"
      "DEBUG=1"
    ];
})
