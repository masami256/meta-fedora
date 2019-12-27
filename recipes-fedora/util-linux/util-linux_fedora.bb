require util-linux.inc

inherit fedora-package
require recipes-fedora/sources/util-linux.inc

FILESPATH_append = ":${COREBASE}/meta/recipes-core/util-linux/util-linux"

SRC_URI += "file://configure-sbindir.patch \
            file://runuser.pamd \
            file://runuser-l.pamd \
            file://ptest.patch \
            file://run-ptest \
            file://display_testname_for_subtest.patch \
            file://avoid_parallel_tests.patch \
"

