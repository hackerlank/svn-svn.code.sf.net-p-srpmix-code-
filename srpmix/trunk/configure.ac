dnl major and minor are reflected to SRPMIX file.
dnl If the directory structure is changed incompatibly, update the major version.
dnl If the directory structure is changed compatibly, update the minor version.
dnl If the source code of srpmix is changed but the directory is not changed,
dnl just increment micro version.

m4_define([pkg_major_version],[3])
m4_define([pkg_minor_version],[104])
m4_define([pkg_micro_version],[0])
m4_define([pkg_name],    [srpmix])
m4_define([pkg_version], pkg_major_version.pkg_minor_version.pkg_micro_version)



AC_INIT(pkg_name, pkg_version)
AC_CONFIG_AUX_DIR(misc/ac-aux)
AM_INIT_AUTOMAKE([no-dist-gzip dist-bzip2])

AC_SUBST(SRPMIX_MAJOR_VERSION, pkg_major_version)
AC_SUBST(SRPMIX_MINOR_VERSION, pkg_minor_version)
AC_SUBST(SRPMIX_MICRO_VERSION, pkg_micro_version)

AC_RPM_RELEASE

AC_OUTPUT([
           Makefile
           misc/Makefile
           misc/ac-aux/Makefile
           misc/m4/Makefile
           misc/makefiles/Makefile
           misc/specs/Makefile
           src/libsrpmix.sh
           src/Makefile
           src/plugins/Makefile
           doc/Makefile
           utils/Makefile
          ])

