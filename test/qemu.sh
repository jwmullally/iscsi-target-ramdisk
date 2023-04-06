#!/bin/sh
set -ex

if [ ! -e build/vm ]; then
    # Make some example disk images using this projects own kernels and
    # disk images. These do not include full dracut iscsi booting, so
    # are only good to test the PXE and iBFT SAN booting
    mkdir -p build/vm.tmp/vdb
    gunzip -qc build/openwrt-imagebuilder-*-x86-64.Linux-x86_64/bin/targets/x86/64/openwrt-*-iscsi-target-ramdisk-x86-64-generic-ext4-combined.img.gz > build/vm.tmp/vda.img || true
    qemu-img convert -f raw -O qcow2 build/vm.tmp/vda.img build/vm.tmp/vda.qcow2
    cp build/images/iscsi-target-ramdisk-kernel.bin build/vm.tmp/vdb/vmlinuz-1.2.3
    cp build/images/iscsi-target-ramdisk-initrd.img build/vm.tmp/vdb/initramfs-1.2.3.img
    mkfs.ext4 -d build/vm.tmp/vdb -U b7b071ef-8c7f-480c-b8d5-a02fdae46f90 build/vm.tmp/vdb.img 1G
    qemu-img convert -f raw -O qcow2 build/vm.tmp/vdb.img build/vm.tmp/vdb.qcow2
    rm -rf build/vm.tmp/vda.img build/vm.tmp/vdb build/vm.tmp/vdb.img
    mv build/vm.tmp build/vm
fi

exec qemu-system-x86_64 \
    -nodefaults \
    -smp 2 \
    -m 256 \
    -no-reboot \
    -nographic \
    -serial mon:stdio \
    -kernel build/images/iscsi-target-ramdisk-kernel.bin \
    -initrd build/images/iscsi-target-ramdisk-initrd.img \
    -nic socket,model=virtio,mac=52:54:00:12:34:56,listen=:1234 \
    -nic user,model=virtio,mac=52:54:00:12:34:57,hostfwd=tcp::30022-:22,hostfwd=tcp::30080-:80,hostfwd=tcp::30081-:81 \
    -drive file=build/vm/vda.qcow2,format=qcow2,if=virtio \
    -drive file=build/vm/vdb.qcow2,format=qcow2,if=virtio \
    -append "console=ttyS0"

