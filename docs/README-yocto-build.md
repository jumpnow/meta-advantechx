# Local Yocto Builds

Instructions for workstation Yocto builds.

The instructions here are specifying a specific directory layout.
You are free to change this layout (Yocto doesn't care), but you will have to modify the example bblayers.conf file.


Checkout the following upstream repos with the branches specified.

The repo URLs, the branches and the commits to checkout are in the meta-advantech-imx8 repo README.md

Create a top layer directory by cloning poky with the name poky-scarthgap

    ~$ cd ~
    ~$ git clone -b scarthgap git://git.yoctoproject.org/poky.git poky-scarthgap

Put everything else under this ~/poky-scarthgap main layer.

    ~$ cd ~/poky-scarthgap

    ~/poky-scarthgap$ git clone -b scarthgap git://git.openembedded.org/meta-openembedded.git
    ~/poky-scarthgap$ git clone -b scarthgap https://git.yoctoproject.org/meta-arm.git
    ~/poky-scarthgap$ git clone -b scarthgap https://github.com/Freescale/meta-freescale.git

At the time of this latest document update, we are using the scarthgap-6.6.52-2.2.0 branch of meta-imx.
This will change as NXP updates the layer.
See the meta-advantech-imx8/README.md for the branch actually being used.

    ~/poky-scarthgap$ git clone -b scarthgap-6.6.52-2.2.0 https://github.com/nxp-imx/meta-imx.git

Now check out the custom meta-advantechx bsp layer repo.
It's a custom layer because the latest from Advantech for this board is Yocto mickledore and I don't want to use stuff that old.

Since I share the above repos with multiple boards, I put this one in its own directory.

    ~$ mkdir advantechx 
    ~$ cd advantechx

    ~/advantechx$ git clone -b scarthgap https://github.com/jumpnow/meta-advantechx.git


So now you should have a directory layout that looks like this

    ~/poky-scarthgap/
        ├── bitbake
        ├── contrib
        ├── documentation
        ├── LICENSE
        ├── LICENSE.GPL-2.0-only
        ├── LICENSE.MIT
        ├── MAINTAINERS.md
        ├── MEMORIAM
        ├── meta
        ├── meta-arm
        ├── meta-freescale
        ├── meta-imx
        ├── meta-openembedded
        ├── meta-poky
        ├── meta-qt6
        ├── meta-selftest
        ├── meta-skeleton
        ├── meta-yocto-bsp
        ├── oe-init-build-env
        ├── README.hardware.md -> meta-yocto-bsp/README.hardware.md
        ├── README.md -> README.poky.md
        ├── README.OE-Core.md
        ├── README.poky.md -> meta-poky/README.poky.md
        ├── README.qemu.md
        ├── scripts
        └── SECURITY.md

    ~/advantechx/
        └── meta-advantechx


Create a build directory under ~/advantechx

    ~/advantechx$ mkdir -p build/conf

Copy the example conf files to the new build/conf directory

    ~/advantechx$ cp meta-advantechx/conf/local.conf.sample build/conf/local.conf
    ~/advantechx$ cp meta-advantechx/conf/bblayers.conf.sample build/conf/bblayers.conf
    ~/advantechx$ cp meta-advantechx/conf/conf-notes.txt build/conf/


There are three lines commented in build/conf/local.conf

    #DL_DIR = "/src/scarthgap"
    #SSTATE_DIR = "/oe2/advantechx/sstate-cache"
    #TMPDIR = "/oe2/advantechx/tmp"

The defaults for each of these is under ~/advantechx/build/ referred to as TOPDIR by Yocto.

I usually specify a different location for each, in particular the DL_DIR or the source download directory.
You may want to share this with other builds on your machine and so move it out of this particular TOPDIR.

For reference, here are the sizes of the respective directories on one of my build workstations

    ~$ du -hs /src/scarthgap/
    27G	/src/scarthgap/

    ~$ du -hs /oe2/advantechx/sstate-cache/
    2.2G    /oe2/advantechx/sstate-cache/

    ~$ du -hs /oe2/advantechx/tmp
    9.4G    /oe2/advantechx/tmp


The build/conf/bblayers.conf files has the locations of the meta layers the build depends on.
If you made any changes to the directory structure above, then update bblayers.conf accordingly.

At this point you can build.

Source the bitbake build environment and specify the TOPDIR for the build.

    ~$ source poky-scarthgap/oe-init-build-env ~/advantechx/build
    This is the default build configuration for the Poky reference distribution.

    ### Shell environment set up for builds. ###

    You can now run 'bitbake <target>'

    Common targets are:

        console-image
        console-dev-image

Use bitbake to build an image

    ~/advantechx/build$ bitbake console-image


If your workstation is missing packages that Yocto requires, bitbake should tell you what to do.

