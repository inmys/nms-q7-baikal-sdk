
#BR=/home/bond/projects/0f_baikal_uq7/sdk/rootfs/buildroot-2020.11
#IMG=$(BR)/output/images
#IMG=../../../output/images

all: $(IMG)/update1.swu $(IMG)/update.swu $(IMG)/confirm.swu $(IMG)/reboot.swu

RSA_PASSW="MyRsaPassw"

$(IMG)/update1.swu: sw-description-updated1 $(IMG)/rootfs.ubi preinstall1.sh sign_priv.pem Makefile
	mkdir -p files_update
	cp preinstall1.sh files_update/
	#openssl enc -aes-256-cbc -in $(IMG)/rootfs.ubi -out files_update/rootfs.ubi -K $(AES_KEY) -iv ${AES_IV}
	cp $(IMG)/rootfs.ubi files_update/rootfs.ubi
	cp sw-description-updated1 files_update/sw-description
	sed "s/sha256_preinstall1.sh/`sha256sum files_update/preinstall1.sh | cut -d ' ' -f 1`/g" -i files_update/sw-description
	sed "s/sha256_rootfs.ubi/`sha256sum files_update/rootfs.ubi | cut -d ' ' -f 1`/g" -i files_update/sw-description
	openssl dgst -sha256 -sign sign_priv.pem -passin pass:"$(RSA_PASSW)" files_update/sw-description > files_update/sw-description.sig
	(cd files_update && for i in sw-description sw-description.sig rootfs.ubi preinstall1.sh; do echo $${i}; done | cpio -ov -H crc > $@)
	rm -rf files_update

$(IMG)/update.swu: sw-description-updated $(IMG)/rootfs.ubi preinstall.sh sign_priv.pem Makefile
	mkdir -p files_update
	cp preinstall.sh files_update/
	#openssl enc -aes-256-cbc -in $(IMG)/rootfs.ubi -out files_update/rootfs.ubi -K $(AES_KEY) -iv ${AES_IV}
	cp $(IMG)/rootfs.ubi files_update/rootfs.ubi
	cp sw-description-updated files_update/sw-description
	sed "s/sha256_preinstall.sh/`sha256sum files_update/preinstall.sh | cut -d ' ' -f 1`/g" -i files_update/sw-description
	sed "s/sha256_rootfs.ubi/`sha256sum files_update/rootfs.ubi | cut -d ' ' -f 1`/g" -i files_update/sw-description
	openssl dgst -sha256 -sign sign_priv.pem -passin pass:"$(RSA_PASSW)" files_update/sw-description > files_update/sw-description.sig
	(cd files_update && for i in sw-description sw-description.sig rootfs.ubi preinstall.sh; do echo $${i}; done | cpio -ov -H crc > $@)
	rm -rf files_update

$(IMG)/confirm.swu: sw-description-confirmed Makefile
	mkdir -p files_confirm
	cp sw-description-confirmed files_confirm/sw-description
	openssl dgst -sha256 -sign sign_priv.pem -passin pass:"MyRsaPassw" files_confirm/sw-description > files_confirm/sw-description.sig
	(cd files_confirm && for i in sw-description sw-description.sig; do echo $${i}; done | cpio -ov -H crc > $@)
	rm -rf files_confirm

$(IMG)/reboot.swu: sw-description-reboot reboot.sh Makefile
	mkdir -p files_reboot
	cp sw-description-reboot files_reboot/sw-description
	cp reboot.sh files_reboot/
	sed "s/sha256_reboot.sh/`sha256sum files_reboot/reboot.sh | cut -d ' ' -f 1`/g" -i files_reboot/sw-description
	openssl dgst -sha256 -sign sign_priv.pem -passin pass:"MyRsaPassw" files_reboot/sw-description > files_reboot/sw-description.sig
	(cd files_reboot && for i in sw-description sw-description.sig reboot.sh; do echo $${i}; done | cpio -ov -H crc > $@)
	rm -rf files_reboot

clean:
	rm -f $(IMG)/update1.swu $(IMG)/update.swu $(IMG)/confirm.swu $(IMG)/reboot.swu
