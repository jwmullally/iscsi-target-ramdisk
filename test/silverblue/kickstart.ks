text
lang en_US.UTF-8
keyboard us
timezone Etc/UTC
firewall --use-system-defaults
services --enabled=sshd
network --hostname test-target-silverblue --bootproto=dhcp --device=enp2s0 --activate
rootpw --plaintext silverblue
shutdown

ignoredisk --only-use=vda
zerombr
clearpart --drives=disk/by-id/virtio-abcd1234 --initlabel --disklabel=gpt
part biosboot --ondrive=disk/by-id/virtio-abcd1234 --fstype=biosboot --size=1
part /boot --ondrive=disk/by-id/virtio-abcd1234 --fstype=ext4 --size=1024 --mkfsoptions="-U b7b071ef-8c7f-480c-b8d5-a02fdae46f90"
part /boot/efi --ondrive=disk/by-id/virtio-abcd1234 --fstype=efi --size=256
part btrfs.599 --fstype="btrfs" --ondisk=vda --grow --mkfsoptions="-U 5b6621d0-15ae-4c93-b9d6-f2a197a9ef06"
btrfs none --label=fedora_fedora btrfs.599
btrfs /home --subvol --name=home LABEL=fedora_fedora
btrfs / --subvol --name=root LABEL=fedora_fedora
btrfs /var --subvol --name=var LABEL=fedora_fedora

ostreesetup --osname="fedora" --remote="fedora" --url="file:///ostree/repo" --ref="fedora/36/x86_64/silverblue" --nogpg

skipx

%post --erroronfail
sed -i 's/^#*PermitRootLogin .*$/PermitRootLogin yes/g' /etc/ssh/sshd_config
systemctl mask NetworkManager-wait-online.service
systemctl set-default multi-user.target
%end
