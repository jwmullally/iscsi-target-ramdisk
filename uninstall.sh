#!/bin/sh
set -ex

HAS_BLS="$(test -d /boot/loader/entries && echo 1 || echo 0)"
HAS_OSTREE="$(test -d /ostree && echo 1 || echo 0)"
HAS_GRUB1="$(test -f /boot/grub/grub.cfg && echo 1 || echo 0)"
HAS_GRUB2="$(test -f /boot/grub2/grub.cfg && echo 1 || echo 0)"
HAS_SYSTEMD="$(test -f /usr/bin/systemctl && echo 1 || echo 0)"
HAS_NETWORKD="$(systemctl --quiet is-enabled systemd-networkd && echo 1 || echo 0)"
HAS_NM="$(test -f /usr/bin/nmcli && echo 1 || echo 0)"

disable_dracut_iscsi() {
    echo "Disabling iSCSI Initiator support in Dracut initramfs"
    rm -f /etc/dracut.conf.d/90-openwrt-iscsi-target.conf
    if [ "$HAS_OSTREE" = "1" ]; then
        (rpm-ostree initramfs | grep -q "Initramfs regeneration: disabled") || rpm-ostree initramfs --disable
    else
        # We have just removed the dracut config containing the hostonly options.
        # If this uninstall script is being run on the initiator, hostonly mode 
        # may result in initramfs that dont run on the original target, so to be
        # safe we use no-hostonly mode once to ensure working initramfs.
        dracut --force --no-hostonly --no-hostonly-cmdline
    fi
}

remove_boot_entry() {
    echo "Removing OpenWrt iSCSI Target boot menu entry"
    if [ "$HAS_BLS" = "1" -a "$HAS_OSTREE" = "0" ]; then
        rm -f /boot/loader/entries/openwrt-iscsi-target.conf
    else
        rm -f /etc/grub.d/42_openwrt-iscsi-target
        if [ "$HAS_GRUB1" = "1" ]; then
            grub-mkconfig -o /boot/grub/grub.cfg
        elif [ "$HAS_GRUB2" = "1" ]; then
            grub2-mkconfig -o /boot/grub2/grub.cfg
        fi
    fi
}

preserve_kernel_cmdline() {
    if [ -f /etc/kernel/cmdline ]; then
        echo "Custom /etc/kernel/cmdline detected, review manually and remove to go back to default cmdline detection (e.g. /etc/default/grub:GRUB_CMDLINE_LINUX)."
    fi
}

remove_bootif_unmanaged() {
    if [ "$HAS_NETWORKD" = "1" ]; then
        echo "Removing setting for iSCSI BOOTIF as unmanaged in systemd-networkd"
        rm -f /etc/systemd/network/00-bootnet-unmanaged.network
    elif [ "$HAS_NM" = "1" -a "$HAS_SYSTEMD" = "1" ]; then
        echo "Removing script to set iSCSI BOOTIF as unmanaged in NetworkManager..."
        systemctl disable bootnet-nm-unmanaged
        rm -f /etc/systemd/system/bootnet-nm-unmanaged.service
    fi
}

disable_dracut_iscsi
remove_boot_entry
preserve_kernel_cmdline
remove_bootif_unmanaged
rm -f /boot/openwrt-iscsi-target-kernel.bin
rm -f /boot/openwrt-iscsi-target-initrd.bin
rm -f /usr/local/sbin/uninstall-openwrt-iscsi-target.sh
