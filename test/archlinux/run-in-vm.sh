#!/bin/bash
set -ex

# Run this in the test VM

cd openwrt-iscsi-target-ramdisk

dependencies/archlinux/build.sh
make images
#dependencies/archlinux/build-iso.sh
#make iso
dependencies/archlinux/install.sh
./install.sh

mv /boot/initramfs-$(uname -r).img /boot/initramfs-linux.img
grub-mkconfig -o /boot/grub/grub.cfg
