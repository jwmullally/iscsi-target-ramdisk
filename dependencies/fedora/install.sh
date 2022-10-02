#!/bin/sh
set -ex

# Dracut iSCSI target support
dnf install $PKGMGR_OPTS \
	dracut-network \
	iscsi-initiator-utils
