#!/bin/bash

IMAGE="${1:-console}"
MACHINE="${2:-imx8ulprom2620a1}"

IMXBOOT="imx-boot-${MACHINE}-1G.bin-flash_singleboot_m33"
WIC="${IMAGE}-image-${MACHINE}.rootfs.wic.zst"

if [ -z "$OETMP" ]; then
    # echo try to find it
    if [ -f ../../build/conf/local.conf ]; then
        OETMP=$(grep '^TMPDIR' ../../build/conf/local.conf | awk '{ print $3 }' | sed 's/"//g')

        if [ -z "$OETMP" ]; then
            OETMP=../../build/tmp
        fi
    fi
fi

SRCDIR="${OETMP}/deploy/images/${MACHINE}"

if [ ! -d $SRCDIR ]; then
    echo "Source dir not found: $SRCDIR"
    exit 1
fi

if [ ! -f "${SRCDIR}/${IMXBOOT}" ]; then
    echo "IMX boot file not found: ${SRCDIR}/${IMXBOOT}"
    exit 1
fi

if [ ! -f "${SRCDIR}/${WIC}" ]; then
    echo "WIC file not found: ${SRCDIR}/${WIC}"
    exit 1
fi

if ! which uuu >/dev/null ; then
    echo "uuu utility not found"
    exit 1
fi


sudo uuu -b emmc_all ${SRCDIR}/${IMXBOOT} ${SRCDIR}/${WIC}
