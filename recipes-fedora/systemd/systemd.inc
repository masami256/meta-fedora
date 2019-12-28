SUMMARY = "A System and service manager"
HOMEPAGE = "http://www.freedesktop.org/wiki/Software/systemd"

DESCRIPTION = "systemd is a system and service manager for Linux, compatible with \
SysV and LSB init scripts. systemd provides aggressive parallelization \
capabilities, uses socket and D-Bus activation for starting services, \
offers on-demand starting of daemons, keeps track of processes using \
Linux cgroups, supports snapshotting and restoring of the system \
state, maintains mount and automount points and implements an \
elaborate transactional dependency-based service control logic. It can \
work as a drop-in replacement for sysvinit."

LICENSE = "GPLv2 & LGPLv2.1"
LIC_FILES_CHKSUM = "file://LICENSE.GPL2;md5=751419260aa954499f7abaabaa882bbe \
                    file://LICENSE.LGPL2.1;md5=4fbd65380cdd255951079008b364516c"

fedora_src_git_rev="a2eaa1c027b9cde96a73d8c729cea33ed5e6e9db"

S = "${WORKDIR}/systemd-stable-${fedora_src_git_rev}"

