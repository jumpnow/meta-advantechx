SUMMARY = "U-boot script for imx8ulp rom2620a1 boards"
LICENSE = "MIT"
LIC_FILES_CHKSUM = "file://${COREBASE}/meta/COPYING.MIT;md5=3da9cfbcb788c80a0384361b4de20420"

COMPATIBLE_MACHINE = "imx8ulp*"

inherit deploy nopackages

DEPENDS = "u-boot-mkimage-native"

SRC_URI = " \
    file://emmc-boot.cmd \
    file://sd-boot.cmd \
"

S = "${WORKDIR}"

do_compile() {
    sed -i "s/DTB/${KERNEL_DEVICETREE_BASENAME}/" ${S}/emmc-boot.cmd
    mkimage -A arm -T script -C none -n "Boot script" -d "${S}/emmc-boot.cmd" emmc-boot.scr

    sed -i "s/DTB/${KERNEL_DEVICETREE_BASENAME}/" ${S}/sd-boot.cmd
    mkimage -A arm -T script -C none -n "Boot script" -d "${S}/sd-boot.cmd" sd-boot.scr
}

do_deploy() {
    install -d ${DEPLOYDIR}
    install -m 0644 emmc-boot.scr ${DEPLOYDIR}/boot.scr
    install -m 0644 sd-boot.scr ${DEPLOYDIR}/sd-boot.scr
}

addtask deploy before do_build after do_compile
