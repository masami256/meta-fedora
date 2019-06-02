#
# fedora-package.bbclass
#

FEDORA_SRC_URI ?= ""
SRC_URI = "${FEDORA_SRC_URI}"

FEDORA_UNPACK_DIR ?= "${WORKDIR}/${BP}"
S = "${FEDORA_UNPACK_DIR}"

# rpm2cpio.sh couldn't parse fedora30's src.rpm file.
# Add path to run our rpm2cpio.sh instead of poky's
python () {
    layer_name = d.getVar('LAYERDIR_FEDORA_fedora', True)
    
    path = '%s/scripts:%s' % (layer_name, d.getVar('PATH'))
    d.setVar('PATH', path)
}

