#!/bin/bash
set -ex

# Run this in the test VM

cd openwrt-iscsi-target-ramdisk

PKGMGR_OPTS="--assumeyes" dependencies/fedora/build.sh
make images
PKGMGR_OPTS="--assumeyes" dependencies/fedora/build-iso.sh
make iso
PKGMGR_OPTS="--assumeyes" dependencies/fedora/install.sh
./install.sh
