#!/bin/sh
set -ex

exec qemu-system-x86_64 \
    -nodefaults \
    -smp 2 \
    -m 256 \
    -no-reboot \
    -display curses \
    -vga cirrus \
    -nic socket,model=virtio,mac=52:54:00:12:34:57,connect=:1234 \
    -boot n


#    -serial mon:stdio \
