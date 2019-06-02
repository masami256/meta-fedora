#
# fedora-package.bbclass
#

FEDORA_SRC_URI ?= ""
SRC_URI = "${FEDORA_SRC_URI}"

FEDORA_UNPACK_DIR ?= "${WORKDIR}/${BP}"
S = "${FEDORA_UNPACK_DIR}"

addtask fedora_unpack_extra after do_unpack before do_fedora_patch
do_fedora_unpack_extra() {
    pkg="${BP}.tar.bz2"
    pkg_path="${WORKDIR}/${pkg}"
    tar xvf ${pkg_path} -C ${WORKDIR}
}

EXPORT_FUNCTIONS do_fedora_unpack_extra

do_fedora_patch() {
    bbnote "apply fedora's patch"
}

EXPORT_FUNCTIONS do_fedora_patch
addtask fedora_patch after do_unpack before do_patch

# rpm2cpio.sh couldn't parse fedora30's src.rpm file.
# Add path to run our rpm2cpio.sh instead of poky's
python () {
    layer_name = d.getVar('LAYERDIR_FEDORA_fedora', True)
    
    path = '%s/scripts:%s' % (layer_name, d.getVar('PATH'))
    d.setVar('PATH', path)
}

