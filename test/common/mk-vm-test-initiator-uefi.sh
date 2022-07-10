#!/bin/sh
set -ex

virt-install \
    --connect qemu:///system \
    --name test-initiator-uefi \
    --ram 2048 \
    --vcpus 2 \
    --arch x86_64 \
    --os-variant fedora36 \
    --disk none \
    --network network=isolated,mac=52:54:00:14:d6:9e \
    --network default,mac=52:54:00:14:d6:9f \
    --boot loader=/usr/share/edk2/ovmf/OVMF_CODE.fd,loader.readonly=yes,loader.type=pflash,nvram.template=/usr/share/edk2/ovmf/OVMF_VARS.fd,loader_secure=no
    --pxe
