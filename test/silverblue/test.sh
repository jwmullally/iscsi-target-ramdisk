#!/bin/bash
set -ex

export SSHPASS=silverblue
sshopts="-o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"
target_ip="$(virsh --quiet -c qemu:///system domifaddr test-target-silverblue | tail -n1 | awk '{print $4}' | cut -d'/' -f1)"
run_cmd="sshpass -e ssh $sshopts root@$target_ip"

if [ "$1" = "shell" ]; then
	$run_cmd
else
	sshpass -e rsync -e "ssh $sshopts" -a --exclude build ../.. "root@$target_ip:openwrt-iscsi-target-ramdisk"

	$run_cmd "openwrt-iscsi-target-ramdisk/test/silverblue/run-in-vm.sh"
fi