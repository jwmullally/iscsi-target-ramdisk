#!/bin/bash
set -ex

export SSHPASS=fedora
sshopts="-o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"
target_ip="$(virsh --quiet -c qemu:///system domifaddr test-target-uefi-fedora | tail -n1 | awk '{print $4}' | cut -d'/' -f1)"
run_cmd="sshpass -e ssh $sshopts root@$target_ip"

if [ "$1" = "shell" ]; then
	$run_cmd
else
	$run_cmd dnf install --assumeyes make rsync
	sshpass -e rsync -e "ssh $sshopts" -a --exclude build ../.. "root@$target_ip:iscsi-target-ramdisk"

	$run_cmd "iscsi-target-ramdisk/test/fedora/run-in-vm.sh"
fi
