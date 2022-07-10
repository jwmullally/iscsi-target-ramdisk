ALL_CURL_OPTS := $(CURL_OPTS) -L --fail --create-dirs

VERSION := 22.03.0-rc5
BOARD := x86
SUBTARGET := 64
BUILDER := openwrt-imagebuilder-$(VERSION)-$(BOARD)-$(SUBTARGET).Linux-x86_64
PROFILE := generic
EXTRA_IMAGE_NAME := iscsi-target
# Example WiFi support: "wpad-wolfssl kmod-iwlwifi iwlwifi-firmware-iwl8265"
PACKAGES := luci tgt blkid lsblk iperf3 luci-app-commands atop tcpdump ethtool

BUILD_DIR := build
OUTPUT_DIR := $(BUILD_DIR)/$(BUILDER)/bin/targets/$(BOARD)/$(SUBTARGET)
OUTPUT_PREFIX := openwrt-$(VERSION)-$(EXTRA_IMAGE_NAME)-$(BOARD)-$(SUBTARGET)-$(PROFILE)


all: images


$(BUILD_DIR)/downloads:
	mkdir -p $(BUILD_DIR)/downloads.tmp
	cd $(BUILD_DIR)/downloads.tmp && curl $(ALL_CURL_OPTS) -O https://downloads.openwrt.org/releases/$(VERSION)/targets/$(BOARD)/$(SUBTARGET)/$(BUILDER).tar.xz
	cd $(BUILD_DIR)/downloads.tmp && curl $(ALL_CURL_OPTS) -O https://www.kernel.org/pub/linux/utils/boot/syslinux/syslinux-6.03.tar.gz && tar -xf syslinux-6.03.tar.gz
	mv $(BUILD_DIR)/downloads.tmp $(BUILD_DIR)/downloads


rootfs-contents: $(BUILD_DIR)/downloads
	rm -rf $(BUILD_DIR)/rootfs
	cp -rv src/rootfs $(BUILD_DIR)/rootfs
	cp -f $(BUILD_DIR)/$(BUILDER)/target/linux/generic/other-files/init $(BUILD_DIR)/rootfs/
	mkdir -p $(BUILD_DIR)/rootfs//srv/tftp/
	cd $(BUILD_DIR)/downloads/syslinux-6.03/bios/ && cp -f \
		core/lpxelinux.0 \
		com32/elflink/ldlinux/ldlinux.c32 \
		com32/menu/menu.c32 \
		com32/menu/vesamenu.c32 \
		com32/lib/libcom32.c32 \
		com32/libutil/libutil.c32 \
		../../../rootfs/srv/tftp/bios
	cd $(BUILD_DIR)/downloads/syslinux-6.03/efi32/ && cp -f \
		efi/syslinux.efi \
		com32/elflink/ldlinux/ldlinux.e32 \
		com32/menu/menu.c32 \
		com32/menu/vesamenu.c32 \
		com32/lib/libcom32.c32 \
		com32/libutil/libutil.c32 \
		../../../rootfs/srv/tftp/efi_x86_32
	cd $(BUILD_DIR)/downloads/syslinux-6.03/efi64/ && cp -f \
		efi/syslinux.efi \
		com32/elflink/ldlinux/ldlinux.e64 \
		com32/menu/menu.c32 \
		com32/menu/vesamenu.c32 \
		com32/lib/libcom32.c32 \
		com32/libutil/libutil.c32 \
		../../../rootfs/srv/tftp/efi_x86_64

$(BUILD_DIR)/$(BUILDER): $(BUILD_DIR)/downloads
	cd $(BUILD_DIR) && tar -xf downloads/$(BUILDER).tar.xz


images: $(BUILD_DIR)/$(BUILDER) rootfs-contents
	cd $(BUILD_DIR)/$(BUILDER) && make image PROFILE="$(PROFILE)" EXTRA_IMAGE_NAME="$(EXTRA_IMAGE_NAME)" PACKAGES="$(PACKAGES)" FILES="../rootfs"
	cat $(OUTPUT_DIR)/sha256sums
	mkdir -p $(BUILD_DIR)/images
	cp $(OUTPUT_DIR)/$(OUTPUT_PREFIX)-kernel.bin $(BUILD_DIR)/images/openwrt-$(EXTRA_IMAGE_NAME)-kernel.bin
	# TODO: Build initramfs image with OpenWrt ImageBuilder built-in Makefile targets
	src/tar2cpio.sh $(OUTPUT_DIR)/$(OUTPUT_PREFIX)-rootfs.tar.gz $(BUILD_DIR)/images/openwrt-$(EXTRA_IMAGE_NAME)-initrd.img
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
	

keys:
	# Create persistent ssh host keys
	mkdir -p src/rootfs/etc/dropbear
	ssh-keygen -N "" -t rsa -b 2048 -f src/rootfs/etc/dropbear/dropbear_rsa_host_key
	ssh-keygen -N "" -t ed25519 -b 256 -f src/rootfs/etc/dropbear/dropbear_ed25519_host_key
	

passwords:
	# TODO: Password rotation


clean:
	rm -rf build

