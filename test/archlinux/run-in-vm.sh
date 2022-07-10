#!/bin/bash
set -ex

# Run this in the test VM

cd openwrt-iscsi-target-ramdisk

dependencies/archlinux/build.sh
make images
#make iso
dependencies/archlinux/install.sh
./install.sh
