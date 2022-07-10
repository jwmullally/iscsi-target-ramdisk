#!/bin/sh
set -ex

virt-install \
    --connect qemu:///system \
    --name test-target-fedora \
    --ram 2048 \
    --vcpus 2 \
    --arch x86_64 \
    --os-variant fedora36 \
    --disk size=8,serial=abcd1234 \
    --disk size=1,serial=eabc5678 \
    --network network=isolated,mac=52:54:00:46:41:46 \
    --network default,mac=52:54:00:46:41:47 \
    --location http://dl.fedoraproject.org/pub/fedora/linux/releases/36/Everything/x86_64/os/ \
    --initrd-inject=fedora-minimal.ks \
    --extra-args "inst.ks=file:/fedora-minimal.ks"
