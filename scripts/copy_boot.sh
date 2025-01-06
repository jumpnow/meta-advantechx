#!/bin/bash

MACHINE="imx8ulprom2620a1"
mnt="/mnt"

reqd_files=("imx-boot" "sd-boot.scr")

if [ "x${1}" = "x" ]; then
    echo "Usage: ${0} <block device>"
    exit 0
fi

mount | grep '^/' | grep -q ${1}

if [ $? -ne 1 ]; then
    echo "Looks like partitions on device /dev/${1} are mounted"
    echo "Not going to work on a device that is currently in use"
    mount | grep '^/' | grep ${1}
    exit 1
fi

if [ -b "/dev/${1}" ]; then
    blockdev=${1}
elif [ -b "/dev/${1}" ]; then
    blockdev=${1}
else
    echo "Block device not found: /dev/${1}"
    exit 1
fi

grep -q [1-9] <(echo $blockdev)

if [ $? -eq 0 ]; then
   echo "Provide a block device only, not a partition: $blockdev"
   exit 1
fi

if [ -b "/dev/${blockdev}1" ]; then
    partition="${blockdev}1"
elif [ -b "/dev/${blockdev}p1" ]; then
    partition="${blockdev}p1"
else
    echo "Partition not found: /dev/${blockdev}1 or /dev/${blockdev}p1"
    echo "Run partitioning script mk2parts.sh or mk5parts.sh before running this script."
    exit 1
fi

echo "MACHINE: $MACHINE"

if [ -z "$OETMP" ]; then
    # echo try to find it
    if [ -f ../../build/conf/local.conf ]; then
        OETMP=$(grep '^TMPDIR' ../../build/conf/local.conf | awk '{ print $3 }' | sed 's/"//g')

        if [ -z "$OETMP" ]; then
            OETMP=../../build/tmp
        fi
    fi
fi

echo "OETMP: $OETMP"

if [ ! -d ${OETMP}/deploy/images/${MACHINE} ]; then
    echo "Directory not found: ${OETMP}/deploy/images/${MACHINE}"
    exit 1
fi

src=${OETMP}/deploy/images/${MACHINE}

for f in "${reqd_files[@]}"; do
    if [ ! -f "${src}/${f}" ]; then
        echo "File not found: ${src}/${f}"
        exit 1
    fi
done

echo "Copying imx-boot to unpartitioned space on /dev/${blockdev}"
sudo dd if="${src}/imx-boot" of="/dev/${blockdev}" conv=notrunc bs=512 seek=64

echo "Formatting FAT partition on /dev/${partition}"
sudo mkfs.vfat "/dev/${partition}" -n "BOOT"

echo "Mounting /dev/${partition} at ${mnt}"
sudo mount "/dev/${partition}" "$mnt"

echo "Copying and renaming sd-boot.scr to ${mnt}/boot.scr"
sudo cp "${src}/sd-boot.scr" "${mnt}/boot.scr"

sudo sync

echo "Umounting /dev/${partition}"
sudo umount "/dev/${partition}"

echo "Done"
