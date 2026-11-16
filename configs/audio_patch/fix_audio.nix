{ pkgs, ... }:
{
  # Firmware del amplificador aw88399 (woofers de la Legion)
  hardware.firmware = [
    (pkgs.runCommand "aw88399-firmware" { } ''
      mkdir -p $out/lib/firmware
      cp ${./aw88399_acf.bin} $out/lib/firmware/aw88399_acf.bin
    '')
  ];
}
