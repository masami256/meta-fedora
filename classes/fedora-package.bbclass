#
# fedora-package.bbclass
#

FEDORA_SRC_URI ?= ""
SRC_URI = "${FEDORA_SRC_URI}"

FEDORA_UNPACK_DIR ?= "${WORKDIR}/${BP}"
S = "${FEDORA_UNPACK_DIR}"

def test(d):
    bb.warn("SRC_URI: %s" % d.getVar('SRC_URI'))
    
python () {
    test(d)
}
