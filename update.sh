#!/bin/sh
set -ex
install -m 0755 build/images/openwrt-iscsi-target-kernel.bin /boot/
install -m 0600 build/images/openwrt-iscsi-target-initrd.img /boot/
