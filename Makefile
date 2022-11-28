ALL_CURL_OPTS := $(CURL_OPTS) -L --fail

#VERSION := 22.03-SNAPSHOT
VERSION := 22.03.2
BOARD := x86
SUBTARGET := 64
BUILDER := openwrt-imagebuilder-$(VERSION)-$(BOARD)-$(SUBTARGET).Linux-x86_64
PROFILE := generic
EXTRA_IMAGE_NAME := iscsi-target
# Example WiFi support: "wpad-openssl kmod-iwlwifi iwlwifi-firmware-iwl8265"
# Example Emulated device support: "kmod-veth wpad-openssl kmod-mac80211-hwsim"
PACKAGES := luci tgt blkid lsblk iperf3 luci-app-commands atop tcpdump ethtool -libustream-wolfssl libustream-openssl luci-ssl-openssl

BUILD_DIR := build
OUTPUT_DIR := $(BUILD_DIR)/$(BUILDER)/bin/targets/$(BOARD)/$(SUBTARGET)


all: images


$(BUILD_DIR)/downloads:
	mkdir -p \
		$(BUILD_DIR)/downloads.tmp \
		$(BUILD_DIR)/downloads.tmp/ipxe/x86 \
		$(BUILD_DIR)/downloads.tmp/ipxe/x86_64
	# OpenWrt Image Builder
	cd $(BUILD_DIR)/downloads.tmp \
		&& curl $(ALL_CURL_OPTS) -O https://downloads.openwrt.org/releases/$(VERSION)/targets/$(BOARD)/$(SUBTARGET)/$(BUILDER).tar.xz
	# iPXE
	cd $(BUILD_DIR)/downloads.tmp/ipxe/x86 \
		&& curl $(ALL_CURL_OPTS) -O https://boot.ipxe.org/ipxe.pxe \
		&& curl $(ALL_CURL_OPTS) -O https://boot.ipxe.org/undionly.kpxe
	cd $(BUILD_DIR)/downloads.tmp/ipxe/x86_64 \
		&& curl $(ALL_CURL_OPTS) -O https://boot.ipxe.org/ipxe.efi \
		&& curl $(ALL_CURL_OPTS) -O https://boot.ipxe.org/snponly.efi
	cd $(BUILD_DIR)/downloads.tmp/ipxe/ \
		&& curl $(ALL_CURL_OPTS) -O https://boot.ipxe.org/ipxe.iso \
		&& curl $(ALL_CURL_OPTS) -O https://boot.ipxe.org/ipxe.usb
	# ISOLINUX for ISO building
	cd $(BUILD_DIR)/downloads.tmp \
		&& curl $(ALL_CURL_OPTS) -O https://www.kernel.org/pub/linux/utils/boot/syslinux/syslinux-6.03.tar.gz \
		&& tar -xf syslinux-6.03.tar.gz
	mv $(BUILD_DIR)/downloads.tmp $(BUILD_DIR)/downloads


rootfs-contents: $(BUILD_DIR)/downloads
	rm -rf $(BUILD_DIR)/rootfs
	cp -rv src/rootfs $(BUILD_DIR)/rootfs
	cp -f $(BUILD_DIR)/$(BUILDER)/target/linux/generic/other-files/init $(BUILD_DIR)/rootfs/
	mkdir -p $(BUILD_DIR)/rootfs/srv/pxe/tftp/ipxe/x86
	cp -f $(BUILD_DIR)/downloads/ipxe/x86/ipxe.pxe $(BUILD_DIR)/rootfs/srv/pxe/tftp/ipxe/x86
	cp -f $(BUILD_DIR)/downloads/ipxe/x86/undionly.kpxe $(BUILD_DIR)/rootfs/srv/pxe/tftp/ipxe/x86
	mkdir -p $(BUILD_DIR)/rootfs/srv/pxe/tftp/ipxe/x86_64
	cp -f $(BUILD_DIR)/downloads/ipxe/x86_64/ipxe.efi $(BUILD_DIR)/rootfs/srv/pxe/tftp/ipxe/x86_64
	cp -f $(BUILD_DIR)/downloads/ipxe/x86_64/snponly.efi $(BUILD_DIR)/rootfs/srv/pxe/tftp/ipxe/x86_64


$(BUILD_DIR)/$(BUILDER): $(BUILD_DIR)/downloads
	cd $(BUILD_DIR) && tar -xf downloads/$(BUILDER).tar.xz


images: $(BUILD_DIR)/$(BUILDER) rootfs-contents
	cd $(BUILD_DIR)/$(BUILDER) && make image PROFILE="$(PROFILE)" EXTRA_IMAGE_NAME="$(EXTRA_IMAGE_NAME)" PACKAGES="$(PACKAGES)" FILES="../rootfs"
	cat $(OUTPUT_DIR)/sha256sums
	mkdir -p $(BUILD_DIR)/images
	cp $(OUTPUT_DIR)/openwrt-*-kernel.bin $(BUILD_DIR)/images/openwrt-$(EXTRA_IMAGE_NAME)-kernel.bin
	# TODO: Build initramfs image with OpenWrt ImageBuilder built-in Makefile targets
	src/tar2cpio.sh $(OUTPUT_DIR)/openwrt-*-rootfs.tar.gz $(BUILD_DIR)/images/openwrt-$(EXTRA_IMAGE_NAME)-initrd.img
	ls -hs $(BUILD_DIR)/images


iso:
	echo "Generating ISO / USB boot image"
	src/create-boot-iso.sh \
		$(BUILD_DIR)/images/openwrt-$(EXTRA_IMAGE_NAME).iso \
		"OpenWrt-$(EXTRA_IMAGE_NAME)" \
		$(BUILD_DIR)/downloads/syslinux-6.03 \
		$(BUILD_DIR)/images/openwrt-$(EXTRA_IMAGE_NAME)-kernel.bin \
		$(BUILD_DIR)/images/openwrt-$(EXTRA_IMAGE_NAME)-initrd.img \
		"consoleblank=600"

efi:
	objcopy \
		--add-section .osrel=src/os-release --change-section-vma .osrel=0x20000 \
		--add-section .cmdline=src/cmdline.txt --change-section-vma .cmdline=0x30000 \
		--add-section .linux=build/images/openwrt-iscsi-target-kernel.bin --change-section-vma .linux=0x2000000 \
		--add-section .initrd=build/images/openwrt-iscsi-target-initrd.img --change-section-vma .initrd=0x3000000 \
		/usr/lib/systemd/boot/efi/linuxx64.efi.stub \
		build/images/openwrt-iscsi-target.efi
	

keys:
	# Create persistent ssh host keys
	mkdir -p src/rootfs/etc/dropbear
	ssh-keygen -N "" -t rsa -b 2048 -f src/rootfs/etc/dropbear/dropbear_rsa_host_key
	ssh-keygen -N "" -t ed25519 -b 256 -f src/rootfs/etc/dropbear/dropbear_ed25519_host_key
	

passwords:
	# TODO: Password rotation


clean:
	rm -rf build

