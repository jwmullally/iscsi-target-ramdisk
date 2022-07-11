#!/bin/bash
set -ex

export SSHPASS=debian
sshopts="-o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"
target_ip="$(virsh --quiet -c qemu:///system domifaddr test-target-debian | tail -n1 | awk '{print $4}' | cut -d'/' -f1)"
run_cmd="sshpass -e ssh $sshopts root@$target_ip"

if [ "$1" = "shell" ]; then
	$run_cmd
else
	$run_cmd apt-get install --yes rsync
	sshpass -e rsync -e "ssh $sshopts" -a --exclude build ../.. "root@$target_ip:openwrt-iscsi-target-ramdisk"

	$run_cmd "openwrt-iscsi-target-ramdisk/test/debian/run-in-vm.sh"
fi