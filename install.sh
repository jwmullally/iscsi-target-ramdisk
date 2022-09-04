#!/bin/sh
set -ex

HAS_BLS="$(test -d /boot/loader/entries && echo 1 || echo 0)"
HAS_OSTREE="$(test -d /ostree && echo 1 || echo 0)"
HAS_GRUB1="$(test -f /boot/grub/grub.cfg && echo 1 || echo 0)"
HAS_GRUB2="$(test -f /boot/grub2/grub.cfg && echo 1 || echo 0)"
HAS_SYSTEMD="$(test -f /usr/bin/systemctl && echo 1 || echo 0)"
HAS_NETWORKD="$(systemctl --quiet is-enabled systemd-networkd && echo 1 || echo 0)"
HAS_NM="$(test -f /usr/bin/nmcli && echo 1 || echo 0)"

uninstall_previous() {
    if [ -f "/usr/local/sbin/uninstall-openwrt-iscsi-target.sh" ]; then
        echo "Previous version detected, uninstalling before continuing..."
        /usr/local/sbin/uninstall-openwrt-iscsi-target.sh
        echo "Previous version uninstalled, continuing with installation"
    fi
}

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

set_bootif_unmanaged() {
    if [ "$HAS_NETWORKD" = "1" ]; then
        echo "Setting iSCSI BOOTIF as unmanaged in systemd-networkd"
        install -m 0644 -T src/bootnet-networkd-unmanaged.network /etc/systemd/network/00-bootnet-unmanaged.network
    elif [ "$HAS_NM" = "1" -a "$HAS_SYSTEMD" = "1" ]; then
        echo "Installing script to set iSCSI BOOTIF as unmanaged in NetworkManager"
        # Post install
        install -m 0644 -T src/bootnet-nm-unmanaged.service /etc/systemd/system/bootnet-nm-unmanaged.service
        systemctl daemon-reload
        systemctl enable bootnet-nm-unmanaged
    fi
}

uninstall_previous
enable_dracut_iscsi
install_boot_entry
preserve_kernel_cmdline
set_bootif_unmanaged
install -m 0755 -T uninstall.sh /usr/local/sbin/uninstall-openwrt-iscsi-target.sh
./update.sh
