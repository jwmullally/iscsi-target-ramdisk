#!/bin/sh
set -ex

# For UEFI + Secure Boot, add "--boot uefi"

virt-install \
    --connect qemu:///system \
    --name test-target-debian \
    --ram 2048 \
    --vcpus 2 \
    --arch x86_64 \
    --os-variant debian11 \
    --disk size=8,serial=abcd1234 \
    --disk size=1,serial=eabc5678 \
    --network network=isolated,mac=52:54:00:46:41:48 \
    --network default,mac=52:54:00:46:41:49 \
    --location https://deb.debian.org/debian/dists/bullseye/main/installer-amd64/ \
    --initrd-inject=preseed.cfg
