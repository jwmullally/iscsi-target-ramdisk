#!/bin/sh
set -ex

# https://openwrt.org/docs/guide-user/additional-software/imagebuilder#debianubuntu
apt-get install $PKGMGR_OPTS --no-install-recommends \
	build-essential \
	file \
	gawk \
	gettext \
	git \
	libncurses5-dev \
	libncursesw5-dev \
	libssl-dev \
	python3 \
	rsync \
	unzip \
	wget \
	xsltproc \
	zlib1g-dev

# Extra build dependencies
apt-get install $PKGMGR_OPTS --no-install-recommends \
	ca-certificates \
	curl
