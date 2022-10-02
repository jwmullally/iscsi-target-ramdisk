#!/bin/sh
set -ex

dnf install $PKGMGR_OPTS --setopt=install_weak_deps=False \
	genisoimage \
	syslinux
