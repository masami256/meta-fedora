DISTRO_NAME = "Fedy"
DISTRO_VERSION = "30"
DISTRO_CODENAME = "f30"
SDK_VENDOR = "-fedysdk"
SDK_VERSION := "${DISTRO_VERSION}"

MAINTAINER = "masami256"
TARGET_VENDOR = "-fedy"

# Add an eventhandler that generates FEDORA_SRC_URI information
# from Fedora rpm repository
INHERIT += "fedora-source"

# currently only Fedora 28 is tested
SANITY_TESTED_DISTROS ?= " \
fedora-28 \n \
fedora-29 \n \
"
# use toolchain mode for Fedora instead of the default
TCMODE ?= "fedy"

FEDORA_MIRROR = "http://ftp.iij.ad.jp"

# Use host's rpm2cpio
HOSTTOOLS += "rpm2cpio"

# systemd

# preferred providers and versions
require conf/distro/include/fedora-preferred-provider.inc
DISTRO_FEATURES_append = " systemd"
DISTRO_FEATURES_BACKFILL_CONSIDERED += "sysvinit"
VIRTUAL-RUNTIME_init_manager = "systemd"
VIRTUAL-RUNTIME_initscripts = "systemd-compat-units"
VIRTUAL-RUNTIME_udev = "systemd-udev"