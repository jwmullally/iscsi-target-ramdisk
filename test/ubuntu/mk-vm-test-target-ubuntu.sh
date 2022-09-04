#!/bin/sh
set -ex

virt-install \
    --connect qemu:///system \
    --name test-target-ubuntu \
    --ram 2048 \
    --vcpus 2 \
    --arch x86_64 \
    --os-variant ubuntu22.04 \
    --disk size=8,serial=abcd1234 \
    --disk size=1,serial=eabc5678 \
    --network network=isolated,mac=52:54:00:46:41:52 \
    --network default,mac=52:54:00:46:41:53 \
    --cdrom /srv/iso/ubuntu-22.04.1-live-server-amd64.iso

#    --location http://archive.ubuntu.com/ubuntu/dists/jammy/main/installer-amd64/
