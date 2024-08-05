
make # build all

make usb_flash.img # usb(and SATA) flash image
# result: usb_flash.img
# dd if=usb_flash.img of=/dev/sdX

make uMulti # spi-nor partition "fitimage" (kernel+rootfs+dtb)
# result: uMulti

make u-boot # spi-nor partition "bootloader"
#result u-boot: src/u-boot/u-boot.bin
make ubootconfig

make kernel
#result kernel: src/kernel/arch/mips/boot/uImage.gz
make kernelconfig

make dtb
#result dtb: src/kernel/arch/mips/boot/dts/baikal/baikal_t1_npb.dtb

make rootfs
#result: buildroot-2022.02.7/output/images/rootfs.cpio.uboot
make rootfsconfig
