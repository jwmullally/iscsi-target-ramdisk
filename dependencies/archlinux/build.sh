#!/bin/sh
set -ex

# https://openwrt.org/docs/guide-user/additional-software/imagebuilder#archmanjaro
pacman --sync --needed $PKGMGR_OPTS \
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
