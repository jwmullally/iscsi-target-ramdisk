#!/bin/sh
set -ex

virt-install \
    --connect qemu:///system \
    --name test-initiator \
    --ram 2048 \
    --vcpus 2 \
    --arch x86_64 \
    --os-variant fedora36 \
    --disk none \
    --network network=isolated,mac=52:54:00:14:d6:9c \
    --network default,mac=52:54:00:14:d6:9d \
    --pxe
