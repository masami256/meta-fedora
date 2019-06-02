#!/bin/sh -euf

die() {
    echo "$*" >&2
    exit 1
}

pkg="$1"
[ -n "$pkg" -a -e "$pkg" ] || die "should pass package name"

rpm2cpio "$1"
