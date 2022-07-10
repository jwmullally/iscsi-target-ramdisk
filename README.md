# openwrt-iscsi-target-ramdisk

## Overview

This simple project builds a preconfigured x86_64 OpenWrt ramdisk image that serves 
your Linux kernels via PXE and disk drives via iSCSI, allowing you to boot
your OS over the network on another computer using Dracut `netroot=iscsi:...`.

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

Try this out first with the VM images in [`test`](test).

*!! Beta software - may prevent your computer from booting. Be comfortable with editing files in /boot,
and have a backup bootdisk/CD/USB in case anything goes wrong*

*!! Currently there is NO ENCRYPTION for the iSCSI endpoint. See TODO
below. For now, only run this on a trusted network with trusted hosts.*

While running, treat disconnecting the network cable like unplugging your harddrive while your computer is
running. Some distributions seem better are recovering the connection than others. Changing the
settings of the network interface carrying the iSCSI traffic can have the same effect.


## Installation

The only changes needed for your OS are to add Dracut iSCSI initiator support to your initramfs, and to create a boot entry for the `OpenWrt iSCSI Target` kernel and initramfs. The [`install.sh`](install.sh) script takes care of this.

Review and adjust the configuration files in this project to match your system.

You'll mainly just want to update:

* [`src/rootfs/etc/uci-defaults/90-custom-bootentries`](src/rootfs/etc/uci-defaults/90-custom-bootentries)

  * `boot_partition`

    * Run `sudo blkid` and replace the UUID with the one from your partition containing `/boot`.

  * `boot_path`

    * Usually `/` if on its own partition, or `/boot/` if its on the main root filesystem.

  * `cmdline_default`

    * Find your default Kernel command line from `/etc/default/grub` or `/proc/cmdline`. Note, this is ignored when it can be read fully from the `/boot/loader/entries` files.

* [`src/rootfs/etc/uci-defaults/90-custom-tgt`](src/rootfs/etc/uci-defaults/90-custom-tgt)

  * Update the list of of block devices to share as iSCSI LUNs.

* [`src/rootfs/etc/uci-defaults/90-custom-password`](src/rootfs/etc/uci-defaults/90-custom-password)

And review:

* [`src/dracut.conf`](src/dracut.conf)

* [`src/bootloaderspec-entry.conf`](src/bootloaderspec-entry.conf)

* [`src/grub-entry.sh`](src/grub-entry.sh)

Then proceed with the build and installation steps below.


### Debian/Ubuntu

NOTE: This replaces `initramfs-tools` with `dracut`.

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

NOTE: This replaces `mkinitcpio` with `dracut`.

```
sudo dependencies/archlinux/build.sh
make images
sudo dependencies/archlinux/install.sh
sudo ./install.sh
```

You may need to move the generated `/boot/initramfs-X.Y.Z-arch1-1.img` file over `/boot/initramfs-linux.img`.


## Updating

After the initial install, this solution should work indefinitely even as you upgrade your kernels.

If you want to make changes to the OpenWrt configuration, you will only need to update `/boot/openwrt-iscsi-target-kernel.bin` and `/boot/openwrt-iscsi-target-initrd.img` by doing the following:

```
make images
sudo ./update.sh
```


## Troubleshooting

On OpenWrt:

* Check `/srv/tftp/pxelinux.cfg/default` and `/srv/tftp/bootentries` contain the expected kernels.

  * Update `/etc/config/bootentries` and rerun `/etc/init.d/bootentries restart` to try find them again.

* Use `logread -f` to keep an eye on the PXE boot TFTP requests.

* Use `tcpdump` to check for incoming DHCP and TFTP requests

* In `/srv/tftp/pxelinux.cfg/default`, set `ALLOWOPTIONS=1` to enable editing cmdline options.

* Check the console or `dmesg` output for Ethernet interface corruption warnings (e.g. some
  `e1000e` models have flaky offloading that needs to be disabled with `ethtool`)

On the initiator PXE boot menu:

* Remove `quiet` from the kernel cmdline to see more debug output during boot.


## How it works

On the target host (containing the OS to remote boot):

* `OpenWrt iSCSI Target` boots with its own kernel and stateless initramfs.
* [`/etc/init.d/bootentries`](src/rootfs/etc/init.d/bootentries) is run which discovers the OS kernel images from the `/boot` partition, copies them to `/srv/tftp/bootentries` and creates entries in `/srv/tftp/pxelinux.cfg/default`.
  * Configuration: [`/etc/uci-defaults/90-custom-bootentries`](src/rootfs/etc/uci-defaults/90-custom-bootentries).
  * If `/boot/loader/entries` is found, all BootLoaderSpec files are parsed to identify kernel images and cmdline arguments. If not found, the `/boot/vmlinuz-*` with the newest modification time is used along with the matching initramfs file, and a boot entry is created with the `cmdline_default` arguments.
  * An optional password is set for the PXE menu. (Note: this just provides user-facing securiry in the PXELINUX menu to prevent accidental booting; boot files and iSCSI credentials can still be sniffed over the network).
* `/etc/init.d/tgt` starts which exports the disk block devices as iSCSI LUN targets.
  * Configuration: [`/etc/uci-defaults/90-custom-tgt`](src/rootfs/etc/uci-defaults/90-custom-tgt).
* `/etc/init.d/dnsmasq` starts which provides DHCP, DHCP boot and serves `/srv/tftp` via TFTP. The DHCP allocation pool is limited to one available address to limit accidental concurrent booting from separate machines and provide some subnet isolation.
  * Configuration: [`/etc/uci-defaults/90-custom-dhcp`](src/rootfs/etc/uci-defaults/90-custom-dhcp).
* [`/etc/init.d/tftp_access`](src/rootfs/etc/init.d/tftp_access) starts and adds uHTTPd server configuration for `/srv/tftp`.

On the initiator host (the one to run the OS on):

* The BIOS starts PXE boot.
* The PXE ROM requests and receives a DHCP boot response, pointing to the PXELINUX binary on TFTP.
* PXELINUX is downloaded and executed, which fetches `/srv/tftp/pxelinux.cfg/default` over TFTP and displays the boot options to the user.
* The user selects a kernel to boot.
* PXELINUX fetches the kernel and associated initramfs over HTTP.
* PXELINUX launches the kernel using the included cmdline arguments, which contain the extra `netroot:iscsi:...` parameters.
* The kernel starts, unpacks and launches the init process in the initramfs.
* The Dracut modules are executed.
* The dracut-network iSCSI module sees the `netroot:iscsi:...` arguments and uses them to start an Open iSCSI initiator connection to the `OpenWrt iSCSI Target` host. If successful, the iSCSI target LUN devices now appear as local block devices.
* Booting continues as normal, mounting the root filesystem using the UUID and other regularly supplied cmdline arguments.
* The target OS is now fully loaded on the initiator host.


## Background

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

The separate OpenWrt system also means you don't have to reconfigure your OS to
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
* Match OpenWrt structure and conventions as much as possible.


## TODO

* Uninstall script.

* Debian: Disable default open-iscsi service by default during normal use to prevent error.

* [MACSEC L2 encryption](https://developers.redhat.com/blog/2016/10/14/macsec-a-different-solution-to-encrypt-network-traffic/) or iSCSI + TLS

* Password encrypted PXELINUX configuration and TFTP files.

* SecureBoot. ([Unlikely?](https://forum.openwrt.org/t/x86-uefi-secure-boot-installation/115666)). Provide instructions for self-signed images with `mokutil`?

* Assign static IP to initiator's network interface instead of NetworkManager managed DHCP.

* Sort "OpenWrt iSCSI Target" entry under OS entries in bootloader menu.

* Change iSCSI from userspace TGT to in-kernel LIO ([Example](doc/rough_comparison_lio_vs_tgtd.png)).

* Hide `rd.iscsi.password` credentials from `/proc/cmdline`


## Reference

- [dracut.conf(5)](http://man7.org/linux/man-pages/man5/dracut.conf.5.html).
- [dracut.cmdline(7)](http://man7.org/linux/man-pages/man7/dracut.cmdline.7.html).
- [BootLoaderSpec](https://www.freedesktop.org/wiki/Specifications/BootLoaderSpec/).


## Author

Copyright (C) 2022 Joseph Mullally

License: [GPLv2](./LICENCE.txt)

Project: <https://github.com/jwmullally/openwrt-iscsi-target-ramdisk>
