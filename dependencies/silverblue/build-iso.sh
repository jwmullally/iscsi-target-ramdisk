#!/bin/sh
set -ex

toolbox create --distro fedora --release f36 iscsi-target-ramdisk-build || true
toolbox run --container iscsi-target-ramdisk-build sudo dependencies/fedora/build-iso.sh