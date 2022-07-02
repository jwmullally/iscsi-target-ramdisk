#!/bin/sh

# Prefix linux and initrd paths with /boot depending on partition setup
# Other useful options: quiet

cat <<'EOF'
menuentry 'OpenWrt iSCSI Target' {
	load_video
	insmod gzio
	insmod part_gpt
	insmod ext2
	echo	'Loading OpenWrt Linux Kernel ...'
	linux	/openwrt-iscsi-target-kernel.bin consoleblank=600
	echo	'Loading OpenWrt initial ramdisk ...'
	initrd	/openwrt-iscsi-target-initrd.img
}
EOF
