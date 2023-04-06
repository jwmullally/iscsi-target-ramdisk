#!/bin/sh
set -e

echo "Content-Type: text/x-shellscript"
echo

. /lib/functions/network.sh
network_flush_cache
network_get_ipaddr lan_addr "lan"

cat <<EOF
#!/bin/sh

set -ex

iscsistart \\
	--initiatorname="$(uci get tgt.1.allow_name)" \\
	--targetname="$(uci get tgt.1.name)" \\
	--tgpt=1 \\
	--address="${lan_addr}" \\
	--username="$(uci get tgt.user_in.user)" \\
	--password="$(uci get tgt.user_in.password)" \\
	--username_in="$(uci get tgt.user_out.user)" \\
	--password_in="$(uci get tgt.user_out.password)"

iscsiadm --mode session --print 3

EOF
