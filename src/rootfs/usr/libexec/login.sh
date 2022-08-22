#!/bin/sh

# Override default /usr/libexec/login.sh.
#
# Always require password login for local consoles.
# It's difficult to set ttylogin=1 with uci-defaults before a local user can
# "Please press Enter to activate this console." without authentication, so
# instead we override the small login script.

#[ "$(uci -q get system.@system[0].ttylogin)" = 1 ] || exec /bin/ash --login

exec /bin/login
