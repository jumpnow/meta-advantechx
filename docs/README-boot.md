# README-boot.md

## Boot Switches

Advantech ROM-2620 Board Boot Switches

    https://ess-wiki.advantech.com.tw/view/ROM-2620_user_guide#Internal_I.2FO.2C_Jummper.2FSwitch_List:


### eMMC Boot

    SW1301 OFF: 3,4       ON: 1,2,5,6
    SW1302 OFF: 1,2,3,5   ON: 4,6

## SD Boot

    SW1301 OFF: 5,6       ON: 1,2,3,4
    SW1302 OFF: 1,2,3,5   ON: 4,6

### Serial download

    SW1301 OFF: 1,2,3,4,5,6
    SW1302 OFF: 1,2,3,4   ON: 5,6


## Storage Devices

The eMMC is at /dev/mmcblk0

The SD card is at /dev/mmcblk2

Here's a running eMMC system with an SD card also present

    root@imx8ulprom2620a1:~# cat /proc/cmdline
    console=ttyLP1,115200 earlycon root=/dev/mmcblk0p2 rootwait rw audit=0

    root@imx8ulprom2620a1:~# lsblk
    NAME         MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
    mmcblk2      179:0    0 29.7G  0 disk
    |-mmcblk2p1  179:1    0   64M  0 part /run/media/BOOT-mmcblk2p1
    `-mmcblk2p2  179:2    0 29.6G  0 part /run/media/ROOT-mmcblk2p2
    mmcblk0      179:32   0 14.7G  0 disk
    |-mmcblk0p1  179:33   0 83.2M  0 part /run/media/boot-mmcblk0p1
    `-mmcblk0p2  179:34   0 14.6G  0 part /
    mmcblk0boot0 179:64   0    4M  1 disk
    mmcblk0boot1 179:96   0    4M  1 disk

And here's a running SD card system

    root@imx8ulprom2620a1:~# cat /proc/cmdline
    console=ttyLP1,115200 earlycon root=/dev/mmcblk2p2 rootwait rw audit=0

    root@imx8ulprom2620a1:~# lsblk
    NAME         MAJ:MIN RM  SIZE RO TYPE MOUNTPOINTS
    mmcblk2      179:0    0 29.7G  0 disk
    |-mmcblk2p1  179:1    0   64M  0 part
    `-mmcblk2p2  179:2    0 29.6G  0 part /
    mmcblk0      179:32   0 14.7G  0 disk
    |-mmcblk0p1  179:33   0 83.2M  0 part
    `-mmcblk0p2  179:34   0 14.6G  0 part
    mmcblk0boot0 179:64   0    4M  1 disk
    mmcblk0boot1 179:96   0    4M  1 disk

## Partitioning

The imx-boot file is a multi-part binary that goes into unpartitioned space at the 32K start position of the boot media.

See description for creating the imx-boot file below.

The imx-boot can be installed like this

    dd if=${SRC}/imx-boot of=${DEV} conv=notrunc bs=512 seek=64

You need to ensure that the first partition of the media leaves space for this.
By default we are starting the first partition at 8MB into the media.

    16384 * 512 bytes/sector = 8 MB

Example with sfdisk

    dd if=/dev/zero of=/dev/<device> bs=1024 count=1024

    {
    echo 16834,131072,0x0C,*
    echo 147906,+,0x83,-
    } | sfdisk /dev/<device>


The default imx way of doing things is to put the kernel, dtbs and any u-boot scripts in the first partition (p1) formatted as FAT

    root@imx8ulprom2620a1:~# mount /dev/mmcblk2p1 /mnt

    root@imx8ulprom2620a1:~# ls -1 /mnt
    Image
    boot.scr
    imx8ulp-rom2620-a1.dtb
    tee.bin

Then the rootfs goes on another Linux partition, normally the p2 partition of the media.

But the kernel and dtbs can be loaded from the rootfs just as well since u-boot understands ext4 file systems.

Keeping the kernel and dtbs on the rootfs facilitates A/B upgrades and so that's where we will be putting them.

So the p1 partition just has the boot.scr if you use the SD card scripts in the repo.

For now we don't require the trusted execution environment binary tee.bin.

## Serial Upgrade

Using the NXP uuu utility, you can do a USB serial upgrade of the eMMC using the artifacts produced by the Yocto build.

You can get the utility here

    https://github.com/nxp-imx/mfgtools/releases

For the console image in the repo you need these two files

* imx-boot-imx8ulprom2620a1-2G.bin-flash\_singleboot\_m33
* console-image-imx8ulprom2620a1.wic.zst

Power off and set the boot switches

    SW1301 OFF: 1,2,3,4,5,6
    SW1302 OFF: 1,2,3,4   ON: 5,6

Attach a USB cable to the micro USB port and power up the board.

You should see the board with uuu

    /tmp$ uuu -lsusb
    uuu (Universal Update Utility) for nxp imx chips -- libuuu_1.5.182-0-gda3cd53

    Connected Known USB Devices
            Path     Chip     Pro     Vid     Pid     BcdVersion     Serial_no
            ====================================================================
            3:2      MX8ULP   SDPS:   0x1FC9  0x014A  0x0001

Attach a serial console to watch in another window, then run uuu

    /tmp$ sudo uuu -b emmc_all imx-boot-imx8ulprom2620a1-1G.bin-flash_singleboot_m33 console-image-imx8ulprom2620a1.wic.zst
    uuu (Universal Update Utility) for nxp imx chips -- libuuu_1.5.182-0-gda3cd53

    Success 1    Failure 0


    3:2-2FF747B2 1/ 1 [=================100%=================] boot -scanterm -f imx-boot-imx8ulprom2620a1-1G.bin-flash_singleboot_m33
    3:2-C3C98AA5 8/ 8 [Done                                  ] FB: done

And then poweroff and reset the switches to eMMC boot

    SW1301 OFF: 3,4       ON: 1,2,5,6
    SW1302 OFF: 1,2,3,5   ON: 4,6

And power on again
