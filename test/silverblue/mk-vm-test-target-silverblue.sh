#!/bin/sh
set -ex

virt-install \
    --connect qemu:///system \
    --name test-target-silverblue \
    --ram 8192 \
    --vcpus 2 \
    --arch x86_64 \
    --os-variant fedora36 \
    --disk size=20,serial=abcd1234 \
    --disk size=1,serial=eabc5678 \
    --network network=isolated,mac=52:54:00:46:41:44 \
    --network default,mac=52:54:00:46:41:45 \
    --location http://dl.fedoraproject.org/pub/fedora/linux/releases/36/Silverblue/x86_64/os/ \
    --initrd-inject=kickstart.ks \
    --extra-args "inst.ks=file:/kickstart.ks"
