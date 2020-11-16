.POSIX:

PREFIX = /usr

CRUST_VER = master
#ATF_VER = master
ATF_VER = 8109d2dd69e2e08c36a094776d37151a65bf37fb
#UBOOT_VER = crust
UBOOT_VER = 7206996ef7f89375dd74b275ced62d85f8bc7f42

OR1K_TOOLCHAIN = or1k-linux-musl-
AARCH64_TOOLCHAIN = aarch64-linux-musl-

SCP_BIN = crust/build/scp/scp.bin
ATF_BIN = arm-trusted-firmware/build/sun50i_a64/debug/bl31.bin
UBOOT_BIN = u-boot-sunxi-with-spl.bin

TCDIR = $(OR1K_TOOLCHAIN)cross $(AARCH64_TOOLCHAIN)cross
TCTGZ = $(TCDIR:=.tgz)

all: $(UBOOT_BIN)

$(TCTGZ):
	wget -c https://musl.cc/$@

$(TCDIR): $(TCTGZ)
	tar xf $@.tgz
	touch $@

toolchains: $(TCDIR)

crust:
	git clone https://github.com/crust-firmware/crust
	cd $@ && git checkout $(CRUST_VER)

$(SCP_BIN): crust
	$(MAKE) -C crust CROSS_COMPILE=$(OR1K_TOOLCHAIN) pinephone_defconfig
	$(MAKE) -C crust CROSS_COMPILE=$(OR1K_TOOLCHAIN) scp

arm-trusted-firmware:
	git clone https://github.com/arm-software/arm-trusted-firmware
	cd $@ && git checkout $(ATF_VER)

$(ATF_BIN): arm-trusted-firmware
	$(MAKE) -C arm-trusted-firmware CROSS_COMPILE=$(AARCH64_TOOLCHAIN) \
		PLAT=sun50i_a64 DEBUG=1 bl31

u-boot:
	git clone https://gitlab.com/pine64-org/u-boot
	cd $@ && git checkout $(UBOOT_VER)

$(UBOOT_BIN): u-boot $(SCP_BIN) $(ATF_BIN)
	$(MAKE) -C u-boot CROSS_COMPILE=$(AARCH64_TOOLCHAIN) \
		BL31=$(CURDIR)/$(ATF_BIN) SCP=$(CURDIR)/$(SCP_BIN) \
		ARCH=arm pinephone_defconfig
	$(MAKE) -C u-boot CROSS_COMPILE=$(AARCH64_TOOLCHAIN) \
		BL31=$(CURDIR)/$(ATF_BIN) SCP=$(CURDIR)/$(SCP_BIN) \
		ARCH=arm
	cp -f u-boot/$@ .

install:
	mkdir -p $(DESTDIR)$(PREFIX)/share/pine64-uboot
	cp -f $(UBOOT_BIN) boot.txt $(DESTDIR)$(PREFIX)/share/pine64-uboot

clean:

distclean: clean
	rm -rf crust arm-trusted-firmware u-boot $(TCTGZ) $(TCDIR)

.PHONY: clean distclean toolchains install
