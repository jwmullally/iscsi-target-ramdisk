# Kickstart file to create minimal Fedora host
# Tested with Fedora 36

text
lang en_US.UTF-8
keyboard us
timezone Etc/UTC
selinux --enforcing
firewall --enabled --service=mdns
services --enabled=sshd,NetworkManager,chronyd
network --hostname test-target-fedora --bootproto=dhcp --device=enp2s0 --activate
rootpw --plaintext pass1234
shutdown

zerombr
clearpart --drives=disk/by-id/virtio-abcd1234 --initlabel --disklabel=gpt
part biosboot --ondrive=disk/by-id/virtio-abcd1234 --fstype=biosboot --size=1
part /boot/efi --ondrive=disk/by-id/virtio-abcd1234 --fstype=efi --size=256
part /boot --ondrive=disk/by-id/virtio-abcd1234 --fstype=ext4 --size=512 --mkfsoptions="-U b7b071ef-8c7f-480c-b8d5-a02fdae46f90"
part / --ondrive=disk/by-id/virtio-abcd1234 --grow --fstype=ext4 --mkfsoptions="-U 5b6621d0-15ae-4c93-b9d6-f2a197a9ef06"

%packages
@core
kernel
%end

%post --erroronfail
sed -i 's/^#*PermitRootLogin .*$/PermitRootLogin yes/g' /etc/ssh/sshd_config
systemctl mask NetworkManager-wait-online.service
%end
