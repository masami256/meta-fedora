#
# fedora-source.bbclass
#

FEDORA_REPO_RELEASES ?= "releases"
FEDORA_REPO_UPDATES ?= "updates"

def mirror_url(d, rel):
    server = d.getVar('FEDORA_MIRROR', True)
    ver = d.getVar('DISTRO_VERSION', True)

    return "%s/pub/linux/Fedora/fedora/linux/%s/%s/Everything/source/tree" % (server, rel, ver)

def srpm_url(d, rel):
    return "${FEDORA_MIRROR}/pub/linux/Fedora/fedora/linux/%s/${DISTRO_VERSION}/Everything/source/tree" % rel
    
def save_to_file(d, srpm_required_list):
    for pkg in srpm_required_list:
        data = srpm_required_list[pkg]
        pkgname = data['location'].split('/')[-1]
        
        src_info = "# This file is generated by fedora-source.bbclass\n\n"
        src_info += 'LICENSE = "%s"\n' % data['license']
        src_info += 'FPV = "%s%s"\n' % (data['version']['ver'], data['version']['rel'])
        src_info += 'FPV_EPOCH = "%s"\n' % data['version']['epoch']
        src_info += 'REPACK_PV = "%s"\n' % data['version']['rel']
        src_info += 'PV = "%s"\n' % data['version']['ver']
        src_info += '\n'
	
        fedora_src_uri = " \\\n"
        fedora_src_uri += "    %s/%s;name=%s \\\n" % (srpm_url(d, data['rel']), data['location'], pkgname)
        
        src_info += 'FEDORA_SRC_URI = "%s"\n' % fedora_src_uri

        src_info += '\n'
    
        src_info += 'SRC_URI[%s.sha256sum] = "%s"\n' % (pkgname, data['checksum'])

        with open(data['inc_filepath'], 'w') as f:
            f.write(src_info)
            
def create_required_sprm_list(source_files, srpmdata):
    ret = {}
    
    for pkg in source_files:
        ret[pkg] = {
            'name': pkg,
            'rel': srpmdata[pkg]['rel'],
            'inc_filepath': source_files[pkg],
            'version': srpmdata[pkg]['version'],
            'checksum': srpmdata[pkg]['checksum'],
            'location': srpmdata[pkg]['location'],
            'license': srpmdata[pkg]['license'],
        }
    return ret

def find_meta_fedora_source_files(d):
    layer_collections = d.getVar('BBFILE_COLLECTIONS')

    layer_name = d.getVar('LAYERDIR_FEDORA_fedora', True)
    if layer_name is None:
        return

    import glob
    target =  "%s/recipes-fedora/sources/*" % layer_name

    files = glob.glob(target)

    ret = {}
    
    for f in files:
        name = f.split('/')[-1].split('.')[0]
        ret[name] = f

    return ret
        
def attrib_tag_name(attr):
    return attr.tag.split('}')[1]

def fetch_srpm_primary_gz_files(d, repomd_list):
    for rel in [ d.getVar('FEDORA_REPO_RELEASES'), d.getVar('FEDORA_REPO_UPDATES') ]:
        repomd = repomd_list[rel]

        url = "%s/%s" % (mirror_url(d, rel), repomd['location'])
        primary_gz = '%s;sha256sum=%s' % (url, repomd['checksum'])
        
        try:
            fetcher = bb.fetch2.Fetch([primary_gz], d)
            fetcher.download()
        except bb.fetch2.BBFetchException as e:
            bb.warn("Failed to fetch primary.gz. Continue building.")
            return False
        
    return True

def read_contents(rel, srpmdata, filename):
    import gzip
    import xml.etree.ElementTree as ET
    
    xmldata = None
    with gzip.open(filename) as f:
        xmldata = f.read().decode('utf-8')
    
    root = ET.fromstring(xmldata)

    for child in root:
        name = None
        for attr in child:
            val = None
            tag = attrib_tag_name(attr)
            if tag == 'name':
                name = attr.text
                srpmdata[name] = {
                    'name': name,
                    'rel': rel,
                }
            elif tag == 'checksum':
                val = attr.text
            elif tag == 'version':
                val = {
                    'epoch': attr.get('epoch'),
                    'ver':  attr.get('ver'),
                    'rel': attr.get('rel'),
                }
            elif tag == 'location':
                val = attr.get('href')
            elif tag == 'format':
                for child_attr in attr:
                    ctag = attrib_tag_name(child_attr)
                    if ctag == 'license':
                        val = child_attr.text
                        tag = 'license'

            if val:
                srpmdata[name][tag] = val 

    return srpmdata

def create_srpm_list(d, repomd_list):
    if not fetch_srpm_primary_gz_files(d, repomd_list):
        return None

    srpmdata = {}
    
    for rel in [ d.getVar('FEDORA_REPO_RELEASES'), d.getVar('FEDORA_REPO_UPDATES') ]:
        primary_file = '%s/%s' % (d.getVar('DL_DIR', True), repomd_list[rel]['location'].split('/')[-1])
        srpmdata = read_contents(rel, srpmdata, primary_file)

    return srpmdata

def read_srpm_repomd_files(d):
    import xml.etree.ElementTree as ET
    import urllib.request

    ret = {}

    for rel in [ d.getVar('FEDORA_REPO_RELEASES'), d.getVar('FEDORA_REPO_UPDATES') ]:
        
        url = "%s/repodata/repomd.xml" % mirror_url(d, rel)
        ret[rel] = {}

        repomd_file = urllib.request.urlopen(url).read()
        root = ET.fromstring(repomd_file.decode('utf-8'))

        for child in root:
            if len(child.attrib) == 0 or not child.attrib['type'] == 'primary':
                continue
            
            for attr in child:
                tag = attrib_tag_name(attr)
                val = None
                if tag == 'checksum':
                    val = attr.text
                elif tag == 'location':
                    val = attr.get('href')
                    
                if val is not None:
                    ret[rel][tag] = val

    return ret

addhandler fedora_source_eventhandler
fedora_source_eventhandler[eventmask] = "bb.event.ParseStarted"

python fedora_source_eventhandler() {
    fedora_source_enabled = d.getVar('FEDORA_SOURCE_ENABLED', True)
    if fedora_source_enabled == '0':
        bb.note("skip task by FEDORA_SOURCE_ENABLED is 0")
        return

    repomd_data = read_repomod = read_srpm_repomd_files(d)

    srpmdata = create_srpm_list(d, repomd_data)
    if srpmdata is None:
       return

    source_files = find_meta_fedora_source_files(d)

    srpm_required_list = create_required_sprm_list(source_files, srpmdata)

    save_to_file(d, srpm_required_list)
    
}
