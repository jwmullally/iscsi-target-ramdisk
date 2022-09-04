#!/bin/sh
set -ex

dnf install --assumeyes --setopt=install_weak_deps=False \
	genisoimage \
	syslinux
