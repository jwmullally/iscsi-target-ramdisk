#!/bin/sh
set -ex

# Dracut iSCSI target support
# On Ubuntu, this replaces the default initramfs-tools
apt-get install --yes --no-install-recommends \
	dracut \
	dracut-network \
	open-iscsi

# TODO: Removing these removes ubuntu-server-minimal etc
#apt-get remove --yes \
#	initramfs-tools \
#	initramfs-tools-core
