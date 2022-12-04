#!/bin/bash
set -ex

# Run this in the test VM

toolbox create --distro fedora --release f36 iscsi-target-ramdisk-build || true
toolbox run --container iscsi-target-ramdisk-build rm -rf /root/iscsi-target-ramdisk
podman cp iscsi-target-ramdisk iscsi-target-ramdisk-build:/root/iscsi-target-ramdisk

toolbox run --container iscsi-target-ramdisk-build sh -c 'PKGMGR_OPTS="--assumeyes" cd /root/iscsi-target-ramdisk && dependencies/fedora/build.sh'
toolbox run --container iscsi-target-ramdisk-build sh -c 'cd /root/iscsi-target-ramdisk && make images'
toolbox run --container iscsi-target-ramdisk-build sh -c 'PKGMGR_OPTS="--assumeyes" cd /root/iscsi-target-ramdisk && dependencies/fedora/build-iso.sh'
toolbox run --container iscsi-target-ramdisk-build sh -c 'cd /root/iscsi-target-ramdisk && make iso'
rm -rf iscsi-target-ramdisk
podman cp iscsi-target-ramdisk-build:/root/iscsi-target-ramdisk iscsi-target-ramdisk 

cd iscsi-target-ramdisk
dependencies/silverblue/install.sh
./install.sh
