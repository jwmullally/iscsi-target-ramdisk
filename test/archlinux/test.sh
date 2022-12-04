#!/bin/bash
set -ex

export SSHPASS=pass1234
sshopts="-o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"
target_ip="$(virsh --quiet -c qemu:///system domifaddr test-target-archlinux | tail -n1 | awk '{print $4}' | cut -d'/' -f1)"
run_cmd="sshpass -e ssh $sshopts root@$target_ip"

if [ "$1" = "shell" ]; then
	$run_cmd
else
	$run_cmd pacman --sync --needed --noconfirm rsync
	sshpass -e rsync -e "ssh $sshopts" -a --exclude build ../.. "root@$target_ip:iscsi-target-ramdisk"

	$run_cmd "iscsi-target-ramdisk/test/archlinux/run-in-vm.sh"
fi