#!/bin/sh
set -ex

# Dracut iSCSI target support
dnf install --assumeyes \
	dracut-network \
	iscsi-initiator-utils
