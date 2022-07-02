## Testing

### Overview

This folder contains scripts to generate minimal Linux VM images
for different distributions, and installs this project in them.
After installation, the VM's can be rebooted into the
`OpenWrt iSCSI Target` boot entry, then the `test-initiator` VM
can be started to test PXE boot to that machine.

Hardcoded partition UUIDs are used so that we can set the configuration
deterministically.

Each VM has 2 network interfaces, one connected to the regular NAT'd
libvirt network for external connectivity, and one connected to the
`isolated` network. The `isolated` network has the host DHCP server
disabled, so the test target VM can provide DHCP and PXE boot directly
to the initiator VM without interference from the host's DHCP server.

### Example workflow

* `cd common`
  * `./create-isolatred-network.sh`
  * `./mk-vm-test-initiator.sh`

* `cd fedora`
  * `./mk-vm-test-target-fedora.sh`
  * `./test.sh`

* Reboot `test-target-fedora` into the `OpenWrt iSCSI Target` entry

* Boot `test-initiator`

* The `test-target-fedora` OS should now be running on the `test-initiator`
  host.


### UEFI vs Legacy BIOS boot

The example VMs use CSM boot by default, as libvirt's UEFI implementation
automatically enables SecureBoot.

If you want to use UEFI anyway for testing, do the following:

* `mk-vm-test-*.sh`: 

  * Add `--boot UEFI`

You may have to add EFI partitions in the kickstart/preseed files.
