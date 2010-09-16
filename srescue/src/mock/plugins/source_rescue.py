# License: GPL2 or later see COPYING
# Written by Masatake YAMATO
# Copyright (C) 2010 Masatake YAMATO <yamato@redhat.com>

# python library imports

# our imports
from mock.trace_decorator import decorate, traceLog, getLog

import mock.util
import sys
import glob
import shutil
import os

requires_api_version = "1.0"

# plugin entry point
decorate(traceLog())
def init(root, opts):
    SourceRescue(root, opts)

class SourceSOS (Exception):
    """Trigger to jump finally block"""
    pass

class SourceRescue(object):
    """Source mount dirs from host into chroot"""
    decorate(traceLog())
    def __init__(self, root, opts):
        self.root = root
        self.opts = opts
        self.shelterdir = opts.get("shelterdir", False) or (root.resultdir + "/" + "srpmix")
        
        if not self.shelterdir:
            raise RuntimeError, "Neither \"shelterdir\" config parameter nor \"resultdir\" config parameter given"
        if os.path.exists(self.shelterdir + "/" + "srpmix"):
            raise RuntimeError, "%s already exists"%self.shelterdir

        root.addHook("prebuild",  self.prebuild)
        root.addHook("postbuild", self.postbuild)

    decorate(traceLog())
    def prebuild(self):
        root = self.root

        specs = glob.glob(root.makeChrootPath(root.builddir, "SPECS", "*.spec"))
        spec = specs[0]
        chrootspec = spec.replace(root.makeChrootPath(), '') # get rid of rootdir prefix

        getLog().info("Synthesizing source code")
        root.doChroot(
                ["bash", "--login", "-c", 'rpmbuild -bp --target %s --nodeps %s' % (root.rpmbuild_arch, 
                                                                                    chrootspec)],
                shell=False,
                logger=root.build_log, 
                timeout=0,
                uid=root.chrootuid,
                gid=root.chrootgid,
                )

        getLog().info("Rescuing source code to %s" % self.shelterdir)
        bd_out = root.makeChrootPath(root.builddir)
        shutil.copytree(bd_out, self.shelterdir, symlinks=False)

        raise SourceSOS

    decorate(traceLog())
    def postbuild(self):
        self.root.clean()
        # 
        sys.exit(0)
