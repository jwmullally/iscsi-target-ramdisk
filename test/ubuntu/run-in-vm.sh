#!/bin/bash
set -ex

# Run this in the test VM

cd openwrt-iscsi-target-ramdisk

PKGMGR_OPTS="--yes" dependencies/ubuntu/build.sh
make images
PKGMGR_OPTS="--yes" dependencies/ubuntu/build-iso.sh
make iso
PKGMGR_OPTS="--yes" dependencies/ubuntu/install.sh
./install.sh
