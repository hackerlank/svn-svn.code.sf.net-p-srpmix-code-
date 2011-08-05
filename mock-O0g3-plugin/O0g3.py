# License: GPL2 or later see COPYING
# Written by Masatake YAMATO
# Copyright (C) 2011 Masatake YAMATO <yamato@redhat.com>

# python library imports

# our imports
from mock.trace_decorator import decorate, traceLog, getLog

import mock.util
import shutil
import os

requires_api_version = "1.0"

# plugin entry point
decorate(traceLog())
def init(root, opts):
    O0g3(root, opts)

class O0g3(object):
    """Source mount dirs from host into chroot"""


    decorate(traceLog())
    def __init__(self, root, opts):
        self.root = root
        self.opts = opts
        self.gcc_O0g3="/usr/share/mock-O0g3-plugin/gcc-O0g3"


        root.addHook("prebuild",  self.prebuild)
        root.addHook("postbuild", self.postbuild)


    decorate(traceLog())
    def prebuild(self):
        getLog().info("Modify the spec file")
        self.modifySpec()

        getLog().info("Replace gcc")
        self.replaceGcc()
        
    def modifySpec(self):
        root = self.root
        specs = glob.glob(root.makeChrootPath(root.builddir, "SPECS", "*.spec"))
        spec = specs[0]
        chrootspec = spec.replace(root.makeChrootPath(), '') # get rid of rootdir prefix
        root.doChroot(
            ["sed", "-i", "-e", "s/^Release: .*/\0.O0g3/", chrootspec],
            shell=False,
            logger=root.build_log, 
            timeout=0,
            uid=root.chrootuid,
            gid=root.chrootgid,
            )
        
    def replaceGcc(self):
        root = self.root
        f = open(root.makeChrootPath("/usr/bin/gcc"), mode='r')
        if f.readline() != "#!/bin/bash":
            shutil.copy(self.gcc_O0g3, root.makeChrootPath("/tmp"))
            root.doChroot(
                ["cp", "/usr/bin/gcc", "/usr/bin/_gcc"],
                shell=False,
                logger=root.build_log, 
                timeout=0,
                uid=root.chrootuid,
                gid=root.chrootgid,
                )
            root.doChroot(
                ["cp", "/tmp/gcc", "/usr/bin/gcc"],
                shell=False,
                logger=root.build_log, 
                timeout=0,
                uid=root.chrootuid,
                gid=root.chrootgid,
                )
        close(f)

    decorate(traceLog())
    def postbuild(self):
        root = self.root
        getLog().info("Revert gcc")
        root.doChroot(
                ["mv", "/usr/bin/_gcc", "/usr/bin/gcc"],
                shell=False,
                logger=root.build_log, 
                timeout=0,
                uid=root.chrootuid,
                gid=root.chrootgid,
                )
# mock --resultdir=/tmp --enable-plugin=O0g3 -r epel-5-x86_64 --rebuild /srv/sources/attic/cradles/ftp.redhat.com/mirror/linux/enterprise/5Server/en/os/SRPMS/device-mapper-multipath-0.4.7-46.el5.src.rpm
