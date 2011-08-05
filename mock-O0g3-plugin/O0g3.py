# License: GPL2 or later see COPYING
# Written by Masatake YAMATO
# Copyright (C) 2011 Masatake YAMATO <yamato@redhat.com>

# python library imports

# our imports
from mock.trace_decorator import decorate, traceLog, getLog

import mock.util
import shutil
import os
import os.path
import glob

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
        self.suffix="O0g3"
        
        # See http://www.redhat.com/archives/rpm-list/2003-February/msg00174.html
        root.yumInstall("redhat-rpm-config")

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
            ["sed", "-i", 
             "-e", 's/^Release: .*/\\0.%s/'%(self.suffix), 
             "-e", "1i %define debug_package %{nil}",
             "-e", "1i %define debug_packages %{nil}",
             "-e", "1i %define __strip :",
             chrootspec],
            shell=False,
            logger=root.build_log, 
            timeout=0,
            uid=root.chrootuid,
            gid=root.chrootgid,
            )
        
    def replaceGcc(self):
        root = self.root
        f = open(root.makeChrootPath("/usr/bin/gcc"), mode='r')
        l = f.readline() 
        f.close()
        if l != "#!/bin/bash":
            try:
                root.uidManager.becomeUser(0, 0)
                mock.util.do(
                    ["/bin/cp", 
                     root.makeChrootPath("/usr/bin/gcc"), 
                     root.makeChrootPath("/usr/bin/_gcc")],
                    shell=False)
                mock.util.do(
                    ["/bin/cp", 
                     self.gcc_O0g3,
                     root.makeChrootPath("/usr/bin/gcc")],
                    shell=False)
            finally:
                root.uidManager.restorePrivs()
    def revertGcc(self):
        root = self.root
        if os.path.exists(root.makeChrootPath("/usr/bin/_gcc")):

            try:
                root.uidManager.becomeUser(0, 0)
                mock.util.do(
                    ["/bin/mv", 
                     root.makeChrootPath("/usr/bin/_gcc"), 
                     root.makeChrootPath("/usr/bin/gcc")],
                    shell=False)
            finally:
                root.uidManager.restorePrivs()
        
    decorate(traceLog())
    def postbuild(self):
        getLog().info("Revert gcc")
        self.revertGcc()

# mock --no-cleanup-after --resultdir=/tmp --enable-plugin=O0g3 -r epel-5-x86_64 --rebuild /srv/sources/attic/cradles/ftp.redhat.com/mirror/linux/enterprise/5Server/en/os/SRPMS/device-mapper-multipath-0.4.7-46.el5.src.rpm 
