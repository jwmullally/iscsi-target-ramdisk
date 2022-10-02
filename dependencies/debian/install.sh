#!/bin/sh
set -ex

# Dracut iSCSI target support
# On Debian, this replaces the default initramfs-tools
apt-get install $PKGMGR_OPTS --no-install-recommends \
	dracut \
	dracut-network \
	open-iscsi

apt-get remove $PKGMGR_OPTS \
	initramfs-tools \
	initramfs-tools-core
