if USE_SVN_RPM_RELEASE
SVN_RELEASE=@RPM_RELEASE@$(shell LANG=C @SVN@ info | grep Revision | cut -d" " -f2)
else
SVN_RELEASE=@RPM_RELEASE@
endif
