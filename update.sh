#!/bin/sh
set -ex
install -m 0755 build/images/iscsi-target-ramdisk-kernel.bin /boot/
install -m 0600 build/images/iscsi-target-ramdisk-initrd.img /boot/
