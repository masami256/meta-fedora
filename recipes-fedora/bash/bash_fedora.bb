require bash.inc

# GPLv2+ (< 4.0), GPLv3+ (>= 4.0)
LICENSE = "GPLv3+"
LIC_FILES_CHKSUM = "file://COPYING;md5=d32239bcb673463ab874e80d47fae504"

inherit fedora-package
require recipes-fedora/sources/bash.inc

FEDORA_UNPACK_DIR="${WORKDIR}/${PN}-5.0"
S="${FEDORA_UNPACK_DIR}"

#B="${S}"

FILESPATH_append = ":${COREBASE}/meta/recipes-extended/bash/bash"
SRC_URI += "file://execute_cmd.patch;striplevel=0 \
           file://mkbuiltins_have_stringize.patch \
           file://build-tests.patch \
           file://test-output.patch \
           file://fix-run-coproc-run-heredoc-run-execscript-run-test-f.patch \
           file://run-ptest \
           file://pathexp-dep.patch \
           "
#file://fix-run-builtins.patch

DEBUG_OPTIMIZATION_append_armv4 = " ${@bb.utils.contains('TUNE_CCARGS', '-mthumb', '-fomit-frame-pointer', '', d)}"
DEBUG_OPTIMIZATION_append_armv5 = " ${@bb.utils.contains('TUNE_CCARGS', '-mthumb', '-fomit-frame-pointer', '', d)}"

BBCLASSEXTEND = "nativesdk"
