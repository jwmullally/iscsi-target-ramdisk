#!/bin/sh
set -ex

# https://openwrt.org/docs/guide-user/additional-software/imagebuilder#centosfedora
dnf install --assumeyes --setopt=install_weak_deps=False \
	@c-development \
	@development-libs \
	@development-tools \
	gawk \
	gettext \
	git \
	libxslt \
	ncurses-devel \
	openssl-devel \
	perl-FindBin \
	python3 \
	wget \
	which \
	zlib-devel \
	zlib-static

# Extra build dependencies
dnf install --assumeyes --setopt=install_weak_deps=False \
	cpio \
	curl
