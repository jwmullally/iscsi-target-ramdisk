#!/bin/sh
set -ex

virt-install \
    --connect qemu:///system \
    --name test-target-win10 \
    --ram 4096 \
    --cpu Skylake-Client-noTSX-IBRS \
    --vcpus 2 \
    --arch x86_64 \
    --os-variant win10 \
    --disk size=20,serial=abcd1234 \
    --disk size=1,serial=eabc5678 \
    --network network=isolated,mac=52:54:00:47:41:50 \
    --network default,mac=52:54:00:47:41:51 \
    --boot loader=/usr/share/edk2/ovmf/OVMF_CODE.fd,loader.readonly=yes,loader.type=pflash,nvram.template=/usr/share/edk2/ovmf/OVMF_VARS.fd,loader_secure=no \
    --cdrom /srv/iso/Win10_21H2_English_x64.iso
