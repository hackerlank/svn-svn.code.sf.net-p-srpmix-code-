m4_define([pkg_name],[sop])
m4_define([pkg_major_version],[0])
m4_define([pkg_minor_version],[3])
m4_define([pkg_micro_version],[3])
m4_define([pkg_version],pkg_major_version.pkg_minor_version.pkg_micro_version)

AC_INIT(pkg_name, pkg_version)
AC_CONFIG_AUX_DIR(misc/ac-aux)
AM_INIT_AUTOMAKE([no-dist-gzip dist-bzip2])
AM_MAINTAINER_MODE

AC_CHECK_PROGS([SRPMIX], [srpmix])
if test "x$SRPMIX" = "x"; then 
   AC_MSG_ERROR(srpmix not found); 
fi

AC_CHECK_PROGS([GOSH], [gosh])
if test "x$GOSH" = "x"; then 
   AC_MSG_ERROR(gosh not found); 
fi

AC_CHECK_PROGS([WGET], [wget])
if test "x$WGET" = "x"; then 
   AC_MSG_ERROR(wget not found); 
fi

AC_CHECK_PROGS([KOJI], [koji])
if test "x$KOJI" = "x"; then 
   AC_MSG_ERROR(koji not found); 
fi

AC_CHECK_PROGS([REPOSYNC],[reposync])
if test "x$REPOSYNC" = "x"; then 
   AC_MSG_ERROR(reposync not found); 
fi

AC_CHECK_PROGS([YUMDOWNLOADER],[yumdownloader])
if test "x$YUMDOWNLOADER" = "x"; then 
   AC_MSG_ERROR(yumdownloader not found); 
fi

AC_CHECK_PROGS([LCOPY_UPDATE],[lcopy-update])
if test "x$LCOPY_UPDATE" = "x"; then 
   AC_MSG_ERROR(lcopy-update not found); 
fi


AC_RPM_RELEASE

AC_OUTPUT([
	Makefile
	misc/Makefile
	misc/ac-aux/Makefile
	misc/specs/Makefile
	misc/specs/sop.spec
	misc/m4/Makefile
	misc/makefiles/Makefile
	src/Makefile
	src/cron/Makefile
	src/cradle-confs/Makefile
	src/dist-mapping/Makefile
	src/dist-mapping/ftp.redhat.com/Makefile
	])


