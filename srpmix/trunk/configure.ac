dnl major and minor are reflected to SRPMIX file.
dnl If the directory structure is changed incompatibly, update the major version.
dnl If the directory structure is changed compatibly, update the minor version.
dnl If the source code of srpmix is changed but the directory is not changed,
dnl just increment micro version.

m4_define([pkg_major_version],[3])
m4_define([pkg_minor_version],[107])
m4_define([pkg_micro_version],[2])
m4_define([pkg_name],    [srpmix])
m4_define([pkg_version], pkg_major_version.pkg_minor_version.pkg_micro_version)



AC_INIT(pkg_name, pkg_version)
AC_CONFIG_AUX_DIR(misc/ac-aux)
AM_INIT_AUTOMAKE([no-dist-gzip dist-bzip2])
AM_MAINTAINER_MODE

AC_SUBST(SRPMIX_MAJOR_VERSION, pkg_major_version)
AC_SUBST(SRPMIX_MINOR_VERSION, pkg_minor_version)
AC_SUBST(SRPMIX_MICRO_VERSION, pkg_micro_version)

AC_RPM_RELEASE

default_test_srpm=
if test "x$USE_MAINTAINER_MODE" = "xyes"; then
	AC_PATH_PROG([SVN], [svn])
	default_test_srpm=tests/test-srpmix-0-0.fc11.src.rpm
fi
AM_CONDITIONAL([USE_SVN_RPM_RELEASE],
	 [test "x$SVN" != "x" && test -d "$srcdir/.svn"])

SRPMIX_PROGS
SRPMIX_ENABLE_PLUGIN_ETAGS
SRPMIX_ENABLE_PLUGIN_CTAGS
SRPMIX_ENABLE_PLUGIN_CSCOPE
SRPMIX_ENABLE_PLUGIN_DOXYGEN
SRPMIX_ENABLE_PLUGIN_HYPERESTRAIER
SRPMIX_ENABLE_PLUGIN_XGETTEXT


dnl recommendations
dnl wget ftp://ftp.redhat.com/pub/redhat/linux/enterprise/5Server/en/os/SRPMS/pstack-1.2-7.2.2.src.rpm
dnl wget ftp://ftp.redhat.com/pub/redhat/linux/enterprise/5Server/en/os/SRPMS/arptables_jf-0.0.8-8.src.rpm

AC_ARG_WITH([test-srpms],
       [AS_HELP_STRING([--with-test-srpms='SRPMS0 ...'],
          [specify the space-separated list of src.rpms for test])],
          [])
#
# Convert relative paths to absolute paths.
#
with_test_srpms2=
for s in ${default_test_srpm} ${with_test_srpms}; do
    if test "x${s}" != x; then
       if test -f "${s}"; then
           b=$(dirname ${s})
           p=$(cd $b; pwd)
           with_test_srpms2="${with_test_srpms2} ${p}/$(basename ${s})"
       else
           AC_MSG_ERROR(${s} not found)
       fi
    fi
done
with_test_srpms=${with_test_srpms2}

AC_SUBST([TEST_SRPMS], [$with_test_srpms])

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
           src/helpers/Makefile
           doc/Makefile
           utils/Makefile
           tests/Makefile
          ])

