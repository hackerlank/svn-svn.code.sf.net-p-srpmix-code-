# PROGRAMS
AC_DEFUN([SRPMIX_PROGS],[
  AC_CHECK_PROGS([BASH], [bash])
  if test "x$BASH" = "x"; then AC_MSG_ERROR(bash not found); fi

  AC_CHECK_PROGS([HARDLINK], [hardlink])
  if test "x$HARDLINK" = "x"; then AC_MSG_ERROR(hardlink not found); fi

  AC_CHECK_PROGS([RPM2CPIO], [rpm2cpio])
  if test "x$RPM2CPIO" = "x"; then AC_MSG_ERROR(rpm2cpio not found); fi

  AC_CHECK_PROGS([CPIO], [cpio])
  if test "x$CPIO" = "x"; then AC_MSG_ERROR(cpio not found); fi

  AC_CHECK_PROGS([GUILE], [guile])
  if test "x$GUILE" = "x"; then AC_MSG_ERROR(guile not found); fi

  AC_CHECK_PROGS([GOSH], [gosh])
  if test "x$GOSH" = "x"; then AC_MSG_ERROR(gosh not found); fi

  AC_CHECK_PROGS([RPM], [rpm])
  if test "x$RPM" = "x"; then AC_MSG_ERROR(rpm not found); fi


  AC_CHECK_PROGS([FASTJAR], [fastjar])
  if test "x$FASTJAR" = "x"; then AC_MSG_ERROR(fastjar not found); fi

  AC_CHECK_PROGS([RPMBUILD], [rpmbuild])
  if test "x$RPMBUILD" = "x"; then AC_MSG_ERROR(rpmbuild not found); fi

  AC_SUBST(SWRFPM, $RPM)
  AC_SUBST(SWRFBUILD, $RPMBUILD)

])

