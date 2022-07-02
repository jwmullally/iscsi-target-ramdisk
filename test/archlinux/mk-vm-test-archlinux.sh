#!/bin/sh
set -ex

virt-install \
    --connect qemu:///system \
    --name test-target-archlinux \
    --ram 2048 \
    --vcpus 2 \
    --arch x86_64 \
    --os-variant archlinux \
    --disk size=8,serial=abcd1234 \
    --disk size=1,serial=eabc5678 \
    --network network=isolated,mac=52:54:00:46:41:41 \
    --network default,mac=52:54:00:46:41:42 \
    --cdrom https://geo.mirror.pkgbuild.com/iso/latest/archlinux-x86_64.iso
