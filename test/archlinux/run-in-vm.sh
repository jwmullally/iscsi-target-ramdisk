#!/bin/bash
set -ex

# Run this in the test VM

cd iscsi-target-ramdisk

PKGMGR_OPTS="--noconfirm" dependencies/archlinux/build.sh
make images
#PKGMGR_OPTS="--noconfirm" dependencies/archlinux/build-iso.sh
#make iso
PKGMGR_OPTS="--noconfirm" dependencies/archlinux/install.sh
./install.sh

mv /boot/initramfs-$(uname -r).img /boot/initramfs-linux.img
grub-mkconfig -o /boot/grub/grub.cfg
