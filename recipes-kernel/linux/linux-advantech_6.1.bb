SUMMARY = "Linux kernel"
SECTION = "kernel"

LICENSE = "GPL-2.0-only"
LIC_FILES_CHKSUM = "file://COPYING;md5=6bc538ed5bd9a7fc9398086aedcd7e46"

DEPENDS += "bc-native bison-native openssl-native util-linux-native xz-native"

inherit kernel

KERNEL_CONFIG_COMMAND = "oe_runmake_call -C ${S} CC="${KERNEL_CC}" O=${B} olddefconfig"

COMPATIBLE_MACHINE = "(imx8ulp*)"

FILESEXTRAPATHS:prepend := "${THISDIR}/linux-advantech-6.1:${THISDIR}/linux-advantech-6.1/dts:"

S = "${WORKDIR}/git"

KERNEL_DEVICETREE = "\
    freescale/${KERNEL_DEVICETREE_BASENAME}.dtb \
"

PV = "6.1.22"
KBRANCH = "adv_6.1.22_2.0.0"
SRCREV = "1f39747e0bc049fd939bd62bd1791a44363f94b1"
SRC_URI = " \
    git://github.com/ADVANTECH-Corp/linux-imx.git;protocol=https;branch=${KBRANCH} \
    file://defconfig \
    file://imx8ulp-rom2620-a1-lt9211-800x480.dts \
    file://imx8ulp-rom2620-a1-lt9211-800x480.dtsi \
"

do_configure:prepend:imx8ulprom2620a1() {
    cp ${WORKDIR}/*.dts* ${S}/arch/arm64/boot/dts/freescale
}
