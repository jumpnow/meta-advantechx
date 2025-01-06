setenv bootdir /boot
setenv bootdev 2
setenv bootpart 2
setenv console ttyLP1,115200 earlycon
setenv fdtaddr 0x83000000
setenv fdtfile DTB.dtb
setenv loadaddr 0x80400000
setenv mmcroot /dev/mmcblk${bootdev}p${bootpart} rootwait rw
setenv options audit=0
setenv setbootargs setenv bootargs console=${console} root=${mmcroot} ${options}
setenv loadfdt load mmc ${bootdev}:${bootpart} ${fdtaddr} ${bootdir}/${fdtfile}
setenv loadimage load mmc ${bootdev}:${bootpart} ${loadaddr} ${bootdir}/Image
if run loadfdt; then
    if run loadimage; then
        run setbootargs
        booti ${loadaddr} - ${fdtaddr}
    fi
fi
