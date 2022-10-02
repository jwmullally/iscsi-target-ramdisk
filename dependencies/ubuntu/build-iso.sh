#!/bin/sh
set -ex

apt-get install $PKGMGR_OPTS --no-install-recommends \
	genisoimage \
	syslinux-utils