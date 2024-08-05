THIRDPARTY?=../thirdparty
BAIKALSDKRUN=$(THIRDPARTY)/baikal-mips-5.6-20210413.run

all: usb_flash.img

TOOLCHAIN=usr/x-tools/mipsel-unknown-linux-gnu/bin
TOOLCHAINABS=$(abspath $(TOOLCHAIN))
CROSS_COMPILE=$(TOOLCHAINABS)/mipsel-unknown-linux-gnu-
$(CROSS_COMPILE)gcc: $(BAIKALSDKRUN)
	$(BAIKALSDKRUN) --tar xf ./usr/x-tools
	touch $@

UBOOTDIR=src/u-boot
$(UBOOTDIR)/Makefile: $(BAIKALSDKRUN)
	$(BAIKALSDKRUN) --tar xf ./src/u-boot
	git init ./src/u-boot
	cd ./src/u-boot && git add .
	cd ./src/u-boot && EMAIL=builder@inmys.ru git commit -m 'sdk 5.6 u-boot'
	touch $@

UPATCH=u-boot.patch
$(UBOOTDIR)/configs/u-boot_defconfig: $(UBOOTDIR)/Makefile $(UPATCH) u-boot_defconfig
	cd $(UBOOTDIR) && patch -p1 < ../../$(UPATCH)
	ln -s ../../../u-boot_defconfig src/u-boot/configs/u-boot_defconfig
	touch $@

$(UBOOTDIR)/.config: $(UBOOTDIR)/configs/u-boot_defconfig
	$(MAKE) ARCH=mips CROSS_COMPILE=$(CROSS_COMPILE) -C $(UBOOTDIR) u-boot_defconfig
	touch $(UBOOTDIR)/.config:

u-boot: $(UBOOTDIR)/.config $(CROSS_COMPILE)gcc
	$(MAKE) ARCH=mips CROSS_COMPILE=$(CROSS_COMPILE) -C $(UBOOTDIR)
	@echo "result u-boot: $(UBOOTDIR)/u-boot.bin"

ubootconfig: $(UBOOTDIR)/.config $(CROSS_COMPILE)gcc
	 $(MAKE) ARCH=mips CROSS_COMPILE=$(CROSS_COMPILE) -C $(UBOOTDIR) menuconfig

ubootclean:
	$(MAKE) ARCH=mips CROSS_COMPILE=$(CROSS_COMPILE) -C $(UBOOTDIR) clean

ubootsavedefconfig:
	$(MAKE) ARCH=mips CROSS_COMPILE=$(CROSS_COMPILE) -C $(UBOOTDIR) savedefconfig


KDIR=src/kernel
$(KDIR)/Makefile: $(BAIKALSDKRUN)
	$(BAIKALSDKRUN) --tar xf ./src/kernel
	git init ./src/kernel
	cd ./src/kernel && git add .
	cd ./src/kernel && EMAIL=builder@inmys.ru git commit -m 'sdk 5.6 kernel'
	touch $@

dtbs_name=baikal_t1_pico_itx
LPATCH=0001-add-signaltek-mb-npb-4-24-bt_v1-support-to-kernel.patch
$(KDIR)/arch/mips/configs/baikal_npb_defconfig: $(KDIR)/Makefile $(LPATCH)
	cd $(KDIR) && patch -p1 < ../../$(LPATCH)
	cd $(KDIR) && patch -p1 < ../../spi-nand-add-as5f14g04snd.diff
	ln -s ../../../../../../../baikal_t1_uq7_som.dts src/kernel/arch/mips/boot/dts/baikal/baikal_t1_uq7_som.dts
	ln -s ../../../../../../../$(dtbs_name).dts src/kernel/arch/mips/boot/dts/baikal/$(dtbs_name).dts
	ln -s ../../../../../baikal_npb_defconfig_kernel src/kernel/arch/mips/configs/baikal_npb_defconfig
	touch $@

$(KDIR)/.config: $(KDIR)/arch/mips/configs/baikal_npb_defconfig $(CROSS_COMPILE)gcc
	$(MAKE) ARCH=mips CROSS_COMPILE=$(CROSS_COMPILE) -C $(KDIR) baikal_npb_defconfig
	touch $@

kernel $(KDIR)/arch/mips/boot/uImage.gz $(KDIR)/arch/mips/boot/vmlinux.bin: $(KDIR)/.config $(CROSS_COMPILE)gcc
	$(MAKE) ARCH=mips CROSS_COMPILE=$(CROSS_COMPILE) -C $(KDIR) uImage.gz
	@echo "result kernel: $(KDIR)/arch/mips/boot/uImage.gz"

kernelconfig:  $(KDIR)/.config $(CROSS_COMPILE)gcc
	$(MAKE) ARCH=mips CROSS_COMPILE=$(CROSS_COMPILE) -C $(KDIR) menuconfig


dtb $(KDIR)/arch/mips/boot/dts/baikal/$(dtbs_name).dtb: $(KDIR)/.config
	$(MAKE) ARCH=mips CROSS_COMPILE=$(CROSS_COMPILE) -C $(KDIR) baikal/$(dtbs_name).dtb
	@echo "result dtb: $(KDIR)/arch/mips/boot/dts/baikal/$(dtbs_name).dtb"

BRVER=2022.02.7
BRDIR=buildroot-$(BRVER)
$(THIRDPARTY)/buildroot-$(BRVER).tar.gz:
	wget https://buildroot.org/downloads/buildroot-$(BRVER).tar.gz -O $@.tmp
	mv $@.tmp $@

$(BRDIR)/Makefile: $(THIRDPARTY)/buildroot-$(BRVER).tar.gz
	tar -xf $(THIRDPARTY)/buildroot-$(BRVER).tar.gz
	tar -xf $(THIRDPARTY)/dl.tar.gz -C $(BRDIR)
	cd $(BRDIR) && patch -p1 < ../nodejs-v8-mips-compile-1.patch
	cd $(BRDIR) && patch -p1 < ../nodejs-v8-mips-compile-2.patch
	cd $(BRDIR) && patch -p1 < ../nodejs-v8-qemu-wrapper.patch
	touch $@

$(BRDIR)/.config: $(BRDIR)/Makefile
	$(MAKE) BR2_EXTERNAL='../br2external_nms' -C $(BRDIR) nms_baikal_t1_uq7_defconfig

rootfs $(BRDIR)/output/images/rootfs.cpio.uboot: $(BRDIR)/.config
	$(MAKE) -C $(BRDIR)
	@echo "result: $(BRDIR)/output/images/rootfs.cpio.uboot"

rootfsconfig: $(BRDIR)/.config
	$(MAKE) -C $(BRDIR) menuconfig

vmlinux.bin.gz: $(KDIR)/arch/mips/boot/vmlinux.bin
	cat $(KDIR)/arch/mips/boot/vmlinux.bin | gzip -9 > vmlinux.bin.gz

multi.its: multi.its.in $(KDIR)/arch/mips/boot/vmlinux.bin
	@echo kernel_entry: `grep " kernel_entry" src/kernel/System.map | awk '{print substr($$1,9,8)}'`
	sed "s/entry = <0x80a014d8/entry = <0x`grep " kernel_entry" src/kernel/System.map | awk '{print substr($$1,9,8)}'`/g" multi.its.in > $@

# vmlinux.bin.gz, $(KDIR)/arch/mips/boot/dts/baikal/$(dtbs_name).dtb, $(BRDIR)/output/images/rootfs.cpio.gz used in multi.its
uMulti: vmlinux.bin.gz $(KDIR)/arch/mips/boot/dts/baikal/$(dtbs_name).dtb $(BRDIR)/output/images/rootfs.cpio.gz multi.its
	mkimage -D "-I dts -O dtb -p 2000" -f multi.its uMulti
	@echo "result uMulti"


bootfiles=$(BRDIR)/output/images/rootfs.cpio.uboot \
	$(KDIR)/arch/mips/boot/dts/baikal/$(dtbs_name).dtb \
	$(KDIR)/arch/mips/boot/uImage.gz
usb_flash.img: $(bootfiles)
	dd if=/dev/zero of=p1.dat bs=1M count=95
	/sbin/mkfs.vfat p1.dat
	$(BRDIR)/output/host/bin/mcopy -i p1.dat $(bootfiles) ::
	$(BRDIR)/output/host/bin/mcopy -i p1.dat $(BRDIR)/output/images/rootfs.cpio.uboot ::/uInitrd
	$(BRDIR)/output/host/bin/mcopy -i p1.dat $(KDIR)/arch/mips/boot/dts/baikal/$(dtbs_name).dtb ::/bfk3.dtb
	$(BRDIR)/output/host/bin/mcopy -i p1.dat $(KDIR)/arch/mips/boot/uImage.gz ::/bfk3.uImage
	mkdir -p tmpdir
	cp -r add/* tmpdir/
	mke2fs -L STORE1 -N 0 -O ^64bit -d tmpdir -m 5 -r 1 -t ext2 p2.dat 64M
	rm -rf tmpdir
	dd if=/dev/zero bs=512 count=2048 of=head.dat
	$(BRDIR)/output/host/bin/genpart -t 0xc  -c -b 2048   -s  196607 | dd of=head.dat bs=1 seek=446 conv=notrunc
	$(BRDIR)/output/host/bin/genpart -t 0x83 -c -b 196608 -s 2097152 | dd of=head.dat bs=1 seek=462 conv=notrunc
	/bin/echo -n -e '\x55\xaa' | dd of=head.dat bs=1 seek=510 conv=notrunc
	cat head.dat p1.dat p2.dat > $@
	rm head.dat p1.dat p2.dat


clean:
	$(MAKE) ARCH=mips CROSS_COMPILE=$(CROSS_COMPILE) -C $(UBOOTDIR) clean
	$(MAKE) ARCH=mips CROSS_COMPILE=$(CROSS_COMPILE) -C $(KDIR) clean
	$(MAKE) -C $(BRDIR) clean

distclean:
	rm -rf $(UBOOTDIR) $(KDIR) src usr $(BRDIR) usb_flash.img


.PHONY: all u-boot ubootconfig kernel kernelconfig dtb rootfs rootfsconfig usb_flash.img clean distclean

