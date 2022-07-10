#!/bin/sh
set -ex

# https://openwrt.org/docs/guide-user/additional-software/imagebuilder#archmanjaro
pacman --sync --needed --noconfirm \
	base-devel \
	gawk \
	gettext \
	git \
	libxslt \
	ncurses \
	openssl \
	python \
	unzip \
	wget \
	zlib



# ISO/USB building
# Disabled by default as syslinux modifies /boot
#pacman --sync --needed --noconfirm \
#	cdrkit \
#	syslinux
