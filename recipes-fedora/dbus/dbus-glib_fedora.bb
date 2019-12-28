SUMMARY = "High level language (GLib) binding for D-Bus"
DESCRIPTION = "GLib bindings for the D-Bus message bus that integrate \
the D-Bus library with the GLib thread abstraction and main loop."
HOMEPAGE = "https://www.freedesktop.org/Software/dbus"
LICENSE = "AFL-2.1 | GPLv2+"
LIC_FILES_CHKSUM = "file://COPYING;md5=cf5b3a2f7083750d504333114e738656 \
                    file://dbus/dbus-glib.h;beginline=7;endline=21;md5=7755c9d7abccd5dbd25a6a974538bb3c"
SECTION = "base"

DEPENDS = "expat glib-2.0 virtual/libintl dbus-glib-native dbus"
DEPENDS_class-native = "glib-2.0-native dbus-native"

inherit fedora-package
require recipes-fedora/sources/dbus-glib.inc

FILESPATH_append += ":${COREBASE}/meta/recipes-core/dbus/dbus"

inherit autotools pkgconfig gettext bash-completion gtk-doc

#default disable regression tests, some unit test code in non testing code
#PACKAGECONFIG_pn-${PN} = "tests" enable regression tests local.conf
PACKAGECONFIG ??= ""
PACKAGECONFIG[tests] = "--enable-tests,,,"

EXTRA_OECONF_class-target = "--with-dbus-binding-tool=${STAGING_BINDIR_NATIVE}/dbus-binding-tool"

PACKAGES += "${PN}-tests"

FILES_${PN} = "${libdir}/lib*${SOLIBS}"
FILES_${PN}-bash-completion += "${libexecdir}/dbus-bash-completion-helper"
FILES_${PN}-dev += "${libdir}/dbus-1.0/include ${bindir}/dbus-glib-tool"
FILES_${PN}-dev += "${bindir}/dbus-binding-tool"

RDEPENDS_${PN}-tests += "dbus-x11"
FILES_${PN}-tests = "${datadir}/${BPN}/tests"

BBCLASSEXTEND = "native"