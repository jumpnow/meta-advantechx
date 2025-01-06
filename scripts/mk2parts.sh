#!/bin/bash

if [ -n "$1" ]; then
    DRIVE=/dev/$1
else
    echo "Usage: sudo $0 <device>"
    echo "Example: sudo $0 sdb"
    exit 1
fi

mount | grep '^/' | grep -q ${1}

if [ $? -ne 1 ]; then
    echo "Looks like partitions on device /dev/${1} are mounted"
    echo "Not going to work on a device that is currently in use"
    mount | grep ${1}
    exit 1
fi

echo "Working on $DRIVE"

echo "Zeroing the MBR"
dd if=/dev/zero of=$DRIVE bs=1024 count=1024

# Default to 2 partitions
# Sectors are 512 bytes
#  8 MB: no partition, MBR, imx-boot
# 64 MB: FAT partition, boot.scr, [tee.bin]
#  4 GB: linux partition, root filesystem

echo -e "\n=== Creating 2 partitions ===\n"
{
echo 16834,8MiB,0x0C,*
echo ,4GiB,0x83,-
} | sfdisk $DRIVE


sleep 1

echo "Done"

