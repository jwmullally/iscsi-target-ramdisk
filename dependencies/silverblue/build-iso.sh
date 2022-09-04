#!/bin/sh
set -ex

toolbox create --distro fedora --release f36 openwrt-iscsi-target-build || true
toolbox run --container openwrt-iscsi-target-build sudo dependencies/fedora/build-iso.sh