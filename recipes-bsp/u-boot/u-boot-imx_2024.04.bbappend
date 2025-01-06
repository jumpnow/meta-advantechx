FILESEXTRAPATHS:prepend := "${THISDIR}/u-boot-imx-2024.04:"

SRC_URI += "file://0001-Rough-port-of-advantech-rom2620-boards.patch"

UUU_BOOTLOADER:mx8-generic-bsp = ""
UUU_BOOTLOADER_TAGGED:mx8-generic-bsp = ""
