inherit kernel
require recipes-kernel/linux/linux-yocto.inc

# Override SRC_URI in a copy of this recipe to point at a different source
# tree if you do not want to build from Linus' tree.
KBRANCH = "f30"
KMETA = "kernel-meta"

SRC_URI = "git://git.kernel.org/pub/scm/linux/kernel/git/jwboyer/fedora.git;name=machine;branch=${KBRANCH}; \
           git://git.yoctoproject.org/yocto-kernel-cache;type=kmeta;name=meta;branch=yocto-5.0;destsuffix=${KMETA}; \
           file://defconfig \
           file://kernel_name.cfg \
           file://kernel_name.cfg \
"

#FILESEXTRAPATHS_prepend := "${THISDIR}/${PN}/files:"
#SRC_URI += "file://kernel_name.cfg"
     
LIC_FILES_CHKSUM = "file://COPYING;md5=bbea815ee2795b2f4230826c0c6b8814"

SRCREV_meta ?= "31de88e51d100f2c3eefb7acb7390b0144bcfc69"

LINUX_VERSION ?= "5.1.15"
LINUX_VERSION_EXTENSION_append = "-fedora"

# Modify SRCREV to a different commit hash in a copy of this recipe to
# build a different release of the Linux kernel.
# tag: v4.2 64291f7db5bd8150a74ad2036f1037e6a0428df2
SRCREV_machine="d8accf63278b4fed29668a4936e6873b466b3cdf"

PV = "${LINUX_VERSION}"
PR = "0"

# Override COMPATIBLE_MACHINE to include your machine in a copy of this recipe
# file. Leaving it empty here ensures an early explicit build failure.
COMPATIBLE_MACHINE = "qemuarm64|qemux86-64"

do_kernel_configme_append() {
  cat ${WORKDIR}/*.cfg >> ${B}/.config
  cat ${WORKDIR}/*.cfg >> ${B}/../defconfig
}
