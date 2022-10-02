#!/bin/bash
set -ex

# Run this in the test VM

toolbox create --distro fedora --release f36 openwrt-iscsi-target-build || true
toolbox run --container openwrt-iscsi-target-build rm -rf /root/openwrt-iscsi-target-ramdisk
podman cp openwrt-iscsi-target-ramdisk openwrt-iscsi-target-build:/root/openwrt-iscsi-target-ramdisk

toolbox run --container openwrt-iscsi-target-build sh -c 'PKGMGR_OPTS="--assumeyes" cd /root/openwrt-iscsi-target-ramdisk && dependencies/fedora/build.sh'
toolbox run --container openwrt-iscsi-target-build sh -c 'cd /root/openwrt-iscsi-target-ramdisk && make images'
toolbox run --container openwrt-iscsi-target-build sh -c 'PKGMGR_OPTS="--assumeyes" cd /root/openwrt-iscsi-target-ramdisk && dependencies/fedora/build-iso.sh'
toolbox run --container openwrt-iscsi-target-build sh -c 'cd /root/openwrt-iscsi-target-ramdisk && make iso'
rm -rf openwrt-iscsi-target-ramdisk
podman cp openwrt-iscsi-target-build:/root/openwrt-iscsi-target-ramdisk openwrt-iscsi-target-ramdisk 

cd openwrt-iscsi-target-ramdisk
dependencies/silverblue/install.sh
./install.sh
