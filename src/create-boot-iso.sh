#!/bin/sh
set -e

if [ $# -ne 6 ]
then
  echo "Create a hybrid CD/USB bootable Linux from Kernel and Initrd files."
  echo "usage: create-boot-iso <output.iso> <name> <syslinux-dir> <kernel.bin> <initrd.img> <options>"
  exit 1
fi

OUTPUT_ISO="$1"
NAME="$2"
SYSLINUX_DIR="$3"
KERNEL="$4"
INITRD="$5"
OPTIONS="$6"

ISOROOT="$(mktemp -d -t isoroot-XXXXXXXXXX)"
trap 'rm -rf "$ISOROOT/isolinux; rmdir $ISOROOT"' EXIT

mkdir "$ISOROOT/isolinux"
cp -r \
  "$SYSLINUX_DIR/bios/core/isolinux.bin" \
  "$SYSLINUX_DIR/bios/com32/elflink/ldlinux/ldlinux.c32" \
  "$SYSLINUX_DIR/bios/com32/menu/menu.c32" \
  "$SYSLINUX_DIR/bios/com32/menu/vesamenu.c32" \
	"$SYSLINUX_DIR/bios/com32/lib/libcom32.c32" \
	"$SYSLINUX_DIR/bios/com32/libutil/libutil.c32" \
  "$ISOROOT/isolinux"

cat > "$ISOROOT/isolinux/isolinux.cfg" << EOF
UI menu.c32
#UI vesamenu.c32
DEFAULT $NAME
PROMPT 1
TIMEOUT 50
LABEL $NAME
 KERNEL vmlinuz
 APPEND initrd=initrd.img $OPTIONS
EOF

cp "$KERNEL" "$ISOROOT/isolinux/vmlinuz"
cp "$INITRD" "$ISOROOT/isolinux/initrd.img"

mkisofs \
    -quiet \
    -eltorito-boot isolinux/isolinux.bin \
    -eltorito-catalog isolinux/boot.cat \
    -no-emul-boot \
    -boot-load-size 4 \
    -boot-info-table \
    -eltorito-alt-boot \
    -output "$OUTPUT_ISO" \
    "$ISOROOT"
isohybrid "$OUTPUT_ISO"

echo "ISO created successfully."
