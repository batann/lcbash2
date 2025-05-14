#!/bin/bash

set -e

ISO_DIR="/home/ISO"
ISO_ORIG="$ISO_DIR/debian-12.5.0-amd64-netinst.iso"
ISO_EXTRACT="$ISO_DIR/iso-extract"
ISO_NEW="$ISO_DIR/debian-custom.iso"
ISOHPDPFX="$ISO_EXTRACT/isolinux/isohdpfx.bin"

# 1. Extract isohdpfx.bin if missing
if [[ ! -f "$ISOHPDPFX" ]]; then
  echo "[+] Extracting isohdpfx.bin from original ISO..."
  mkdir -p /tmp/iso-mount
  sudo mount -o loop "$ISO_ORIG" /tmp/iso-mount
  cp /tmp/iso-mount/isolinux/isohdpfx.bin "$ISOHPDPFX"
  sudo umount /tmp/iso-mount
fi

# 2. Validate required files
for f in \
  "$ISO_EXTRACT/isolinux/isohdpfx.bin" \
  "$ISO_EXTRACT/isolinux/isolinux.bin" \
  "$ISO_EXTRACT/boot/grub/efi.img"; do
    [[ -f "$f" ]] || { echo "[-] Missing: $f"; exit 1; }
done

# 3. Build new ISO
echo "[+] Building new ISO at $ISO_NEW..."
xorriso -as mkisofs \
  -o "$ISO_NEW" \
  -isohybrid-mbr "$ISO_EXTRACT/isolinux/isohdpfx.bin" \
  -c isolinux/boot.cat \
  -b isolinux/isolinux.bin \
     -no-emul-boot -boot-load-size 4 -boot-info-table \
  -eltorito-alt-boot \
  -e boot/grub/efi.img \
     -no-emul-boot \
  -isohybrid-gpt-basdat \
  -V "Debian Custom" \
  "$ISO_EXTRACT"

echo "[+] Done."

