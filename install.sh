#!/bin/sh
set -ex

HAS_BLS="$(test -d /boot/loader/entries && echo 1 || echo 0)"
HAS_OSTREE="$(test -d /ostree && echo 1 || echo 0)"
HAS_GRUB1="$(test -f /boot/grub/grub.cfg && echo 1 || echo 0)"
HAS_GRUB2="$(test -f /boot/grub2/grub.cfg && echo 1 || echo 0)"

enable_dracut_iscsi() {
    echo "Enabling iSCSI Initiator support in Dracut initramfs"
    install -m 0644 -T src/dracut.conf /etc/dracut.conf.d/90-openwrt-iscsi-target.conf
    if [ "$HAS_OSTREE" = "1" ]; then
        (rpm-ostree initramfs | grep -q "Initramfs regeneration: enabled") || rpm-ostree initramfs --enable
    else
        dracut --force
    fi
}

install_boot_entry() {
    echo "Installing OpenWrt iSCSI Target boot menu entry"
    if [ "$HAS_BLS" = "1" -a "$HAS_OSTREE" = "0" ]; then
        install -m 0644 -T src/bootloaderspec-entry.conf /boot/loader/entries/openwrt-iscsi-target.conf
    else
        install -m 0755 -T src/grub-entry.sh /etc/grub.d/42_openwrt-iscsi-target
        if [ "$HAS_GRUB1" = "1" ]; then
            grub-mkconfig -o /boot/grub/grub.cfg
        elif [ "$HAS_GRUB2" = "1" ]; then
            grub2-mkconfig -o /boot/grub2/grub.cfg
        fi
    fi
}

preserve_kernel_cmdline() {
    # Prevent new kernel installs from using iSCSI initiator /proc/cmdline
    # for regular bootloader entries.
    # Only installed with BootLoaderSpec scripts are in use.
    # See /usr/lib/kernel/install.d/90-loaderentry.install
    if [ "$HAS_BLS" = "1" -a "$HAS_OSTREE" = "0" -a ! -f /etc/kernel/cmdline -a ! -f /usr/lib/kernel/cmdline ]; then
        echo "Preserving current kernel cmdline for future boot loader entries"
        BOOT_OPTIONS=""
        for i in $(cat /proc/cmdline); do
            if [ "${i#initrd=*}" = "$i" -a "${i#BOOT_IMAGE=*}" = "$i" ]; then
                BOOT_OPTIONS="${BOOT_OPTIONS}${i} "
            fi
        done
        echo "$BOOT_OPTIONS" > /etc/kernel/cmdline
    fi
}

enable_dracut_iscsi
install_boot_entry
preserve_kernel_cmdline
./update.sh
