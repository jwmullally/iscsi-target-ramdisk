#!/bin/bash
set -ex

# Run this in the test VM

cd openwrt-iscsi-target-ramdisk

dependencies/ubuntu/build.sh
make images
dependencies/ubuntu/build-iso.sh
make iso
dependencies/ubuntu/install.sh
./install.sh
