#!/bin/sh
set -ex

virt-install \
    --connect qemu:///system \
    --name test-target-freebsd \
    --ram 2048 \
    --vcpus 2 \
    --arch x86_64 \
    --machine q35 \
    --boot loader=/usr/share/edk2/ovmf/OVMF_CODE.fd,loader.readonly=yes,loader.type=pflash,nvram.template=/usr/share/edk2/ovmf/OVMF_VARS.fd,loader_secure=no \
    --os-variant freebsd13.1 \
    --disk size=16,serial=abcd1234 \
    --disk size=1,serial=eabc5678 \
    --network network=isolated,mac=52:54:00:46:48:48 \
    --network default,mac=52:54:00:46:48:49 \
    --cdrom /srv/iso/FreeBSD-13.1-RELEASE-amd64-dvd1.iso

    #--cdrom https://download.freebsd.org/ftp/releases/amd64/amd64/ISO-IMAGES/13.1/FreeBSD-13.1-RELEASE-amd64-dvd1.iso
