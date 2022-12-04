#!/bin/sh

# Prefix linux and initrd paths with /boot depending on partition setup
# Other useful options: quiet

cat <<'EOF'
menuentry 'iSCSI Target Ramdisk' {
	load_video
	insmod gzio
	insmod part_gpt
	insmod ext2
	echo	'Loading Kernel ...'
	linux	/iscsi-target-ramdisk-kernel.bin consoleblank=600
	echo	'Loading Initial Ramdisk ...'
	initrd	/iscsi-target-ramdisk-initrd.img
}
EOF
