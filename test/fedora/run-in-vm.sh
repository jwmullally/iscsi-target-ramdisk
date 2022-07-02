#!/bin/bash
set -ex

# Run this in the test VM

cd openwrt-iscsi-target-ramdisk

dependencies/fedora/build.sh
make images
make iso
dependencies/fedora/install.sh
./install.sh
