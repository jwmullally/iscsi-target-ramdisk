#!/bin/sh
set -ex

# Dracut iSCSI target support
pacman --sync --needed $PKGMGR_OPTS \
	dracut \
	open-iscsi

pacman --remove $PKGMGR_OPTS \
	mkinitcpio \
	|| echo "No package to remove"
