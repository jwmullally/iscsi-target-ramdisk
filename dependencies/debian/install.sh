#!/bin/sh
set -ex

# Dracut iSCSI target support
# On Debian, this replaces the default initramfs-tools
apt-get install --yes --no-install-recommends \
	dracut \
	dracut-network \
	open-iscsi

apt-get remove --yes \
	initramfs-tools \
	initramfs-tools-core
