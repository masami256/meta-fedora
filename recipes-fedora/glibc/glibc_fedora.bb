
inherit fedora-package
require recipes-fedora/sources/glibc.inc

FILESPATH_append = ":${COREBASE}/meta/recipes-core/glibc/glibc"
require ${COREBASE}/meta/recipes-core/glibc/glibc.inc
require ${COREBASE}/meta/recipes-core/glibc/glibc-version.inc

DEPENDS += "gperf-native bison-native make-native"
RDEPENDS_tzcode = "bash"

NATIVESDKFIXES ?= ""
NATIVESDKFIXES_class-nativesdk = "\
           file://0001-nativesdk-glibc-Look-for-host-system-ld.so.cache-as-.patch \
           file://0002-nativesdk-glibc-Fix-buffer-overrun-with-a-relocated-.patch \
           file://0003-nativesdk-glibc-Raise-the-size-of-arrays-containing-.patch \
           file://0004-nativesdk-glibc-Allow-64-bit-atomics-for-x86.patch \
           file://0005-nativesdk-glibc-Make-relocatable-install-for-locales.patch \
"

SRC_URI +=  "file://etc/ld.so.conf \
           file://generate-supported.mk \
           file://makedbs.sh \
           \
           ${NATIVESDKFIXES} \
           "
	   
S="${WORKDIR}/glibc-2.29-12-g0941350c20"
B = "${WORKDIR}/build-${TARGET_SYS}"

PACKAGES_DYNAMIC = ""

# the -isystem in bitbake.conf screws up glibc do_stage
BUILD_CPPFLAGS = "-I${STAGING_INCDIR_NATIVE}"
TARGET_CPPFLAGS = "-I${STAGING_DIR_TARGET}${includedir}"

GLIBC_BROKEN_LOCALES = ""

GLIBCPIE ??= ""

EXTRA_OECONF = "--enable-kernel=${OLDEST_KERNEL} \
                --disable-profile \
                --disable-debug --without-gd \
                --enable-clocale=gnu \
                --with-headers=${STAGING_INCDIR} \
                --without-selinux \
                --enable-tunables \
                --enable-bind-now \
                --enable-stack-protector=strong \
                --enable-stackguard-randomization \
                --disable-crypt \
                --with-default-link \
                --enable-nscd \
                ${@bb.utils.contains_any('SELECTED_OPTIMIZATION', '-O0 -Og', '--disable-werror', '', d)} \
                ${GLIBCPIE} \
                ${GLIBC_EXTRA_OECONF}"

EXTRA_OECONF += "${@get_libc_fpu_setting(bb, d)}"

do_patch_append() {
    bb.build.exec_func('do_fix_readlib_c', d)
}

do_fix_readlib_c () {
	sed -i -e 's#OECORE_KNOWN_INTERPRETER_NAMES#${EGLIBC_KNOWN_INTERPRETER_NAMES}#' ${S}/elf/readlib.c
}

do_configure () {
# override this function to avoid the autoconf/automake/aclocal/autoheader
# calls for now
# don't pass CPPFLAGS into configure, since it upsets the kernel-headers
# version check and doesn't really help with anything
        (cd ${S} && gnu-configize) || die "failure in running gnu-configize"
        find ${S} -name "configure" | xargs touch
        CPPFLAGS="" oe_runconf
}

do_compile () {
	# -Wl,-rpath-link <staging>/lib in LDFLAGS can cause breakage if another glibc is in staging
	LDFLAGS="-fuse-ld=bfd"
	base_do_compile
	echo "Adjust ldd script"
	if [ -n "${RTLDLIST}" ]
	then
		prevrtld=`cat ${B}/elf/ldd | grep "^RTLDLIST=" | sed 's#^RTLDLIST="\?\([^"]*\)"\?$#\1#'`
		# remove duplicate entries
		newrtld=`echo $(printf '%s\n' ${prevrtld} ${RTLDLIST} | LC_ALL=C sort -u)`
		echo "ldd \"${prevrtld} ${RTLDLIST}\" -> \"${newrtld}\""
		sed -i ${B}/elf/ldd -e "s#^RTLDLIST=.*\$#RTLDLIST=\"${newrtld}\"#"
	fi
}

require ${COREBASE}/meta/recipes-core/glibc/glibc-package.inc

BBCLASSEXTEND = "nativesdk"
