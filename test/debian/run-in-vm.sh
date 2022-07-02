#!/bin/bash
set -ex

# Run this in the test VM

cd openwrt-iscsi-target-ramdisk

dependencies/debian/build.sh
make images
make iso
dependencies/debian/install.sh
./install.sh
