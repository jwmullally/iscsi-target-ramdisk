#!/bin/sh
set -ex

virsh -c qemu:///system net-define isolated-network.xml
virsh -c qemu:///system net-autostart isolated