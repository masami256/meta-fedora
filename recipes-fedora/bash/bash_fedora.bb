# GPLv2+ (< 4.0), GPLv3+ (>= 4.0)
LICENSE = "GPLv3+"
LIC_FILES_CHKSUM = "file://COPYING;md5=d32239bcb673463ab874e80d47fae504"

inherit fedora-package
require recipes-fedora/sources/bash.inc

FEDORA_UNPACK_DIR="${WORKDIR}/${PN}-5.0"
S="${FEDORA_UNPACK_DIR}"

require bash.inc
FILESPATH_append = ":${COREBASE}/meta/recipes-extended/bash/bash"

SRC_URI += "file://run-ptest \
           file://run-bash-ptests \
           "

BBCLASSEXTEND = "nativesdk"
