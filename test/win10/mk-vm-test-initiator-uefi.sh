#!/bin/sh
set -ex

virt-install \
    --connect qemu:///system \
    --name test-initiator-win10 \
    --ram 4096 \
    --cpu Skylake-Client-noTSX-IBRS \
    --vcpus 2 \
    --arch x86_64 \
    --os-variant win10 \
    --disk none \
    --network network=isolated,mac=52:54:00:16:d6:9e \
    --network default,mac=52:54:00:16:d6:9f \
    --boot loader=/usr/share/edk2/ovmf/OVMF_CODE.fd,loader.readonly=yes,loader.type=pflash,nvram.template=/usr/share/edk2/ovmf/OVMF_VARS.fd,loader_secure=no \
    --pxe
