inherit kernel
require recipes-kernel/linux/linux-yocto.inc

# Override SRC_URI in a copy of this recipe to point at a different source
# tree if you do not want to build from Linus' tree.
KBRANCH = "f30"
KMETA = "kernel-meta"

FEDORA_KERNEL_REPO ?= "git://git.kernel.org/pub/scm/linux/kernel/git/jwboyer/fedora.git"
SRC_URI = "${FEDORA_KERNEL_REPO};name=machine;branch=${KBRANCH}; \
           git://git.yoctoproject.org/yocto-kernel-cache;type=kmeta;name=meta;branch=yocto-5.0;destsuffix=${KMETA}; \
           file://qemuarm64-defconfig \
	   file://qemux86-64-defconfig \
"

LIC_FILES_CHKSUM = "file://COPYING;md5=bbea815ee2795b2f4230826c0c6b8814"

SRCREV_meta ?= "31de88e51d100f2c3eefb7acb7390b0144bcfc69"

LINUX_VERSION = "5.1.15"
LINUX_VERSION_EXTENSION = "-fedy"

# Modify SRCREV to a different commit hash in a copy of this recipe to
# build a different release of the Linux kernel.
# tag: v4.2 64291f7db5bd8150a74ad2036f1037e6a0428df2
SRCREV_machine="d8accf63278b4fed29668a4936e6873b466b3cdf"

PV = "${LINUX_VERSION}"
PR = "0"

# Override COMPATIBLE_MACHINE to include your machine in a copy of this recipe
# file. Leaving it empty here ensures an early explicit build failure.
COMPATIBLE_MACHINE = "qemuarm64|qemux86-64"
