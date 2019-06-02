DISTRO_NAME = "Fedy"
DISTRO_VERSION = "30"
DISTRO_CODENAME = "f30"
SDK_VENDOR = "-fedysdk"
SDK_VERSION := "${DISTRO_VERSION}"

MAINTAINER = "masami256"
TARGET_VENDOR = "-fedy"

LINUX_GIT_URI ??= "git://git.kernel.org/pub/scm/linux/kernel/git/cip"
LINUX_GIT_PROTOCOL ??= "https"
LINUX_GIT_PREFIX ??= ""
LINUX_GIT_REPO ??= "linux-cip.git"
LINUX_GIT_BRANCH ??= "linux-4.19.y-cip"
LINUX_GIT_SRCREV ??= "${LINUX_GIT_BRANCH}"

# Add an eventhandler that generates FEDORA_SRC_URI information
# from Fedora rpm repository
INHERIT += "fedora-source"

# currently only Fedora 28 is tested
SANITY_TESTED_DISTROS ?= " \
fedora-28 \n \
"
# use toolchain mode for Fedora instead of the default
TCMODE ?= "fedy"

# preferred providers and versions
require conf/distro/include/fedora-preferred-provider.inc

FEDORA_MIRROR = "http://ftp.iij.ad.jp"