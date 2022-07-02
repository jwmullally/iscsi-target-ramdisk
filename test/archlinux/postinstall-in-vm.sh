#!/bin/sh

pacman --sync --needed --noconfirm \
	openssh

sed -i 's/^#*PermitRootLogin .*$/PermitRootLogin yes/g' /etc/ssh/sshd_config
systemctl enable sshd
systemctl start sshd

tune2fs -O metadata_csum_seed -U b7b071ef-8c7f-480c-b8d5-a02fdae46f90 /dev/vda1
tune2fs -O metadata_csum_Seed -U 5b6621d0-15ae-4c93-b9d6-f2a197a9ef06 /dev/vda2

sed -i 's/.*--set=root.*//g' /boot/grub/grub.cfg
sed -i 's/root=UUID=[^ ]*/root=UUID=5b6621d0-15ae-4c93-b9d6-f2a197a9ef06/g' /boot/grub/grub.cfg

cat > /etc/fstab <<EOF
UUID=b7b071ef-8c7f-480c-b8d5-a02fdae46f90 /boot ext4 rw,relatime 0 2
UUID=5b6621d0-15ae-4c93-b9d6-f2a197a9ef06 / ext4 rw,relatime 0 1
EOF
