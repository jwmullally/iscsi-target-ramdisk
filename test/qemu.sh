#!/bin/sh
set -ex
exec qemu-system-x86_64 \
    -nodefaults \
    -smp 2 \
    -m 256 \
    -no-reboot \
    -nographic \
    -serial mon:stdio \
    -kernel build/images/iscsi-target-ramdisk-kernel.bin \
    -initrd build/images/iscsi-target-ramdisk-initrd.img \
    -nic user,model=virtio \
    -nic user,model=virtio,hostfwd=tcp::30022-:22,hostfwd=tcp::30080-:80,hostfwd=tcp::30081-:81 \
    -append "console=ttyS0"
