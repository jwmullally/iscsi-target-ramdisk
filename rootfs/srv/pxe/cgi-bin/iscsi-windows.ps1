#!/bin/sh
set -e

echo "Content-Type: text/x-powershell"
echo

. /lib/functions/network.sh
network_flush_cache
network_get_ipaddr lan_addr "lan"

cat <<EOF
Start-Service -Name MSiSCSI
Set-Service -Name MSiSCSI -StartupType Automatic

Set-InitiatorPort \`
    -NodeAddress (Get-InitiatorPort).NodeAddress \`
    -NewNodeAddress "$(uci get tgt.1.allow_name)"

Set-IscsiChapSecret \`
    -ChapSecret "$(uci get tgt.user_out.password)"

New-IscsiTargetPortal \`
    -TargetPortalAddress "${lan_addr}"

Connect-IscsiTarget \`
    -TargetPortalAddress "${lan_addr}" \`
    -NodeAddress "$(uci get tgt.1.name)" \`
    -AuthenticationType MUTUALCHAP \`
    -ChapUsername "$(uci get tgt.user_in.user)" \`
    -ChapSecret "$(uci get tgt.user_in.password)" \`
    -IsPersistent \$true

Update-HostStorageCache
Get-Disk
EOF
