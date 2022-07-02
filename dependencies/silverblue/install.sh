#!/bin/sh
set -ex

# Dracut iSCSI target support
rpm-ostree install --idempotent \
	dracut-network \
	iscsi-initiator-utils
