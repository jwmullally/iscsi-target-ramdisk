# openwrt-iscsi-target-ramdisk

## Overview

This simple project builds a preconfigured x86_64 OpenWrt ramdisk image that serves 
your Linux kernels via PXE and disk drives via iSCSI, allowing you to boot
your OS over the network on another computer using Dracut `netroot=iscsi:`.

For example, you can run your laptop OS on your more powerful desktop while
still having access to all your laptop's files and programs.

Furthermore, you can customize the OpenWrt build with any additional features
you want.

![Usage Diagram](doc/overview.png)


## Usage

* Connect your two computers via Ethernet

* On the computer where this is installed (target), power on and select
  `OpenWrt iSCSI Target` from the boot menu.

* Power on the other computer (initiator), select the BIOS's built-in PXE boot

* The target OS should now be running on the initiator

If you want to share network/WiFi connections from the target to the initiator:

* Connect to <http://192.168.200.1> to access the OpenWrt Admin UI and
  configure network routing / WiFi, etc.


## Requirements

* Linux

* Disable SecureBoot (see TODO below)

* PXE BIOS Boot


## Precautions

Try this out first with the VM images in `test`.

*!! Beta software - may prevent your computer from booting. Be comfortable with editing files in /boot,
and have a backup bootdisk/CD/USB in case anything goes wrong*

*!! Currently there is NO ENCRYPTION for the iSCSI endpoint. See TODO
below. For now, only run this on a trusted network with trusted hosts.*

While running, treat disconnecting the network cable like unplugging your harddrive while your computer is
running. Some distributions seem better are recovering the connection than others. Changing the
settings of the network interface carrying the iSCSI traffic can have the same effect.


## Installation

Review and adjust the configuration files in this project to match your system.

You'll mainly just want to update:

* [`src/rootfs/etc/uci-defaults/90-custom-bootentries`](src/rootfs/etc/uci-defaults/90-custom-bootentries)

  * `boot_partition`

    * Run `blkid` and replace the UUID with the one from your partition containing `/boot`

  * `boot_path`

    * Usually `/` if on its own partition, or `/boot/` if its on the main root filesystem.

  * `cmdline_default`

    * Find your default Kernel command line from your grub config or `/proc/cmdline`. Note, this is ignored when it can be read fully from `/boot/loader/entries` files.

* [`src/rootfs/etc/uci-defaults/90-custom-tgt`](src/rootfs/etc/uci-defaults/90-custom-tgt)

  * Update the list of of block devices to share as iSCSI LUNs.


### Debian/Ubuntu

NOTE: This replaces `initramfs-tools` with `dracut`

```
sudo dependencies/debian/build.sh
make images
sudo dependencies/debian/install.sh
sudo ./install.sh
```

### Fedora

```
sudo dependencies/fedora/build.sh
make images
sudo dependencies/fedora/install.sh
sudo ./install.sh
```

### Fedora Silverblue

```
dependencies/silverblue/build.sh
toolbox run --container openwrt-iscsi-target-build make images
sudo dependencies/silverblue/install.sh
sudo ./install.sh
```

### Arch

```
sudo dependencies/archlinux/build.sh
make images
sudo dependencies/archlinux/install.sh
sudo ./install.sh
```


## Updating

After the initial install, this solution should work indefinitely even as you upgrade your kernels.

If you want to make changes to the OpenWrt configuration, you will only need to update `/boot/openwrt-iscsi-target-kernel.bin` and `/boot/openwrt-iscsi-target-initrd.img` by doing the following:

```
make images
sudo ./update.sh
```


## Troubleshooting

On OpenWrt: Check `/srv/tftp/pxelinux.cfg/default` and `/srv/tftp/bootentries` contain the expected kernels. Update `/etc/config/bootentries` and rerun `/etc/init.d/bootentries restart` to try find them again.

On OpenWrt: use `logread -f` to keep an eye on the PXE boot progress.

On the initiator PXE boot menu: Remove `quiet` from the kernel cmdline to see more debug output during boot.


## How it works

Typical Linux distributions use a simple boot loader (e.g. GRUB) to load the Linux
Kernel and an [Initial ramdisk](https://en.wikipedia.org/wiki/Initial_ramdisk)
root file system. The purpose of this root filesystem is to do everything
necessary to prepare the storage block devices and mount the real root filesystem.
This provides the OS with great flexibility about how the root filesystem
is stored, for example on different types of network storage, logical volumes,
RAID arrays, encrypted filesystems etc. All the configuration and complexity is
handled by software in the Initial Ramdisk; all the kernel needs is a final
logical block device that it can pass to the filesystem layer for mounting the
root partition, and continue the init boot sequence.

Modern Linux distributions also use UUID-based partition identification in
/etc/fstab, which makes them work deterministically even when the names of
the underlying block devices change (e.g. /dev/sda, /dev/sdb ordering when
other drives or USB keys are inserted).

Here, we add standard iSCSI Initiator support to the Initial Ramdisk
using the Dracut iSCSI module, and supply the necessary kernel cmdline
paramaters to start it. During the Initial Ramdisk init sequence, it will
connect over the network to the iSCSI target, and those block devices
will appear as local block devices.

But from the target computer, we also need to share the kernel images and
disk drives over the network somehow. We can't use the original OS itself
to share them, as the filesystems can be only mounted and used by one computer
at a time, otherwise data corruption would occur.

This is where the OpenWrt ramdisk image comes in. This is a standalone mini-OS
with just enough functionality to share the drives via iSCSI and serve the
kernels via PXE. It is stateless and runs completely from RAM, so the iSCSI
initiator has exclusive read/write access to the drive.

The seperate OpenWrt system also means you don't have to reconfigure your OS to
do all this sharing, which can be complicated and interfere with regular
operation.

An advantage of this block-device based approach compared to NFS, etc. is that
the OS is totally agnostic to what is going on underneath the block devices,
and considers the iSCSI devices to be the same as the regular disk block
devices. In practice, this means you can do upgrades, kernel updates,
bootloader changes, etc. as if you were doing them on the original computer.
On modern systems, you should get full 1GB/s transfer speed and relatively low IOP
latency.

As modern Linux distributions are mostly plug and play, there should be little
issue with your OS seeing a completely different set of hardware.

When the PXE files are being prepared, discovering the kernels and initramfs images
is a bit tricky as the naming conventions and paths varies between distributions.
We parse every BootLoaderSpec spec files found and copy the referenced images.
Parsing grub config is more complicated in comparison, so in that case we simply
select the most recent kernel+initrd files and supply the default cmdline.


## Developing

Patches are welcome.

* Test with the sample VMs in [`test`](test) before opening a pull request.
* Match OpenWrt structure and conventions as much as possible


## TODO

* Uninstall script

* Debian: Disable default open-iscsi service by default during normal use to prevent error

* [MACSEC L2 encryption](https://developers.redhat.com/blog/2016/10/14/macsec-a-different-solution-to-encrypt-network-traffic/)

* SecureBoot. ([Unlikely?](https://forum.openwrt.org/t/x86-uefi-secure-boot-installation/115666)). Provide instructions for self-signed images with `mokutil`?

* UEFI PXE binaries

* Assign static IP to initiator's network interface instead of NetworkManager managed DHCP

* Sort "OpenWrt iSCSI Target" entry under OS entries in bootloader menu


## Reference

- [dracut.conf(5)](http://man7.org/linux/man-pages/man5/dracut.conf.5.html)
- [dracut.cmdline(7)](http://man7.org/linux/man-pages/man7/dracut.cmdline.7.html)
- [BootLoaderSpec](https://www.freedesktop.org/wiki/Specifications/BootLoaderSpec/)


## Author

Copyright (C) 2022 Joseph Mullally

License: [GPLv2](./LICENCE.txt)

Project: <https://github.com/jwmullally/openwrt-iscsi-target-ramdisk>
