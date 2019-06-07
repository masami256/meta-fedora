#
# fedora-package.bbclass
#

FEDORA_SRC_URI ?= ""
SRC_URI = "${FEDORA_SRC_URI}"

FEDORA_UNPACK_DIR ?= ""

def create_src_uri_list(workdir, sources):
    src_list = []

    for src in sorted(sources.keys()):
        s = sources[src]
        if '/' in s:
            s = s.split('/')[-1]
	
        src_list.append("file://%s/%s" %  (workdir, s))

    return src_list
    
def read_contents(spec, key):
    contents = {}

    lines = spec.parsed.split('\n')
    for line in lines:
        if line.startswith(key):
            tmp = line.split(':')
            k = 0

            if tmp[0][-1].isdigit():
                k = int(tmp[0].replace(key, ''))
            v = ''.join(tmp[1:])
            contents[k] = v.strip()

    return contents

def unpack_fedora_sources(d, spec, workdir):
    import os
    import shutil
	  
    sources = read_contents(spec, 'Source')
    src_list = create_src_uri_list(workdir, sources)

    fetcher = bb.fetch2.Fetch(src_list, d)

    # Replace S to unpack_dir
    unpack_dir = d.getVar('FEDORA_UNPACK_DIR', True)
    if not unpack_dir == '':
        s = d.getVar('S', True)
	
        if os.path.isdir(s):
            shutil.rmtree(s)

        d.setVar('S', unpack_dir)
	
    fetcher.unpack(workdir) 

def read_rpm_spec_file(d, workdir, pkgname):
    import rpm
    spec_path = '%s/%s.spec' % (workdir, pkgname)

    macros = {
        '_sourcedir': '%s/%s' % (workdir, pkgname)
    }

    for macro in macros:
        rpm.addMacro(macro, macros[macro])

    spec = rpm.spec(spec_path)

    return spec

def write_fedora_patches_list(d, spec, workdir):
    patches = read_contents(spec, 'Patch')

    patch_list = '%s/fedora_patches.txt' % workdir

    # write patch list to use in do_fedora_patch task.
    with open(patch_list, 'w') as f:
        for patch in sorted(patches):
            line = '%s/%s\n' % (workdir, patches[patch])
            f.write(line)
	  
addtask fedora_unpack_extra after do_unpack before do_fedora_patch
python do_fedora_unpack_extra() {
    workdir = d.getVar('WORKDIR', True)
    pkgname= d.getVar('BPN', True)

    spec = read_rpm_spec_file(d, workdir, pkgname)

    unpack_fedora_sources(d, spec, workdir)

    write_fedora_patches_list(d, spec, workdir)
}

EXPORT_FUNCTIONS do_fedora_unpack_extra

do_fedora_patch() {
    patch_list=$(cat "${WORKDIR}/fedora_patches.txt")

    curr=$(pwd)
    cd ${S}
    for patch in ${patch_list};
    do
        patch -p1 < ${patch}
    done
    cd ${curr}
}

EXPORT_FUNCTIONS do_fedora_patch
addtask fedora_patch after do_fedora_unpack_extra before do_patch

# rpm2cpio.sh couldn't parse fedora30's src.rpm file.
# Add path to run our rpm2cpio.sh instead of poky's
python () {
    layer_name = d.getVar('LAYERDIR_FEDORA_fedora', True)
    
    path = '%s/scripts:%s' % (layer_name, d.getVar('PATH'))
    d.setVar('PATH', path)
}

