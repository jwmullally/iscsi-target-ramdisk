#!/bin/sh
set -ex

apt-get install --yes --no-install-recommends \
	genisoimage \
	syslinux-utils