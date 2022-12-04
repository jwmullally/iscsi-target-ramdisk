#!/bin/bash
set -ex

# Run this in the test VM

cd iscsi-target-ramdisk

PKGMGR_OPTS="--yes" dependencies/debian/build.sh
make images
PKGMGR_OPTS="--yes" dependencies/debian/build-iso.sh
make iso
PKGMGR_OPTS="--yes" dependencies/debian/install.sh
./install.sh
