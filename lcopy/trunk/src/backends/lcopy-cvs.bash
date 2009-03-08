function cvs_p
{
    test -d CVS
}

function cvs_checkout
{
    local repo=$1
    local dir=$2
    local module=$3

    echo cvs -d${repo} checkout -P -d ${dir} ${module} 
}

function cvs_checkout_print_usage
{
    echo "	" cvs -d:pserver:USER:PASSWD@HOST 'checkout|co' -d PACKAGEDIR MODULE 
    echo "	" '(adds -P automatically)'
}

function cvs_checkout_parse_cmdline
{
    local original=$@
    VCS=$1
    REPO=${2/-d/}
    CMD=$3
    shift 3

    if test "x$VCS" != xcvs; then
	echo "wrong vcs: $VCS" 2>&1
	return 1
    fi

    if test \( -z "$CMD"          \) -o       \
	    \(                                \
               \( "$CMD" != co       \) -a    \
               \( "$CMD" != checkout \)       \
            \) ; then
	echo "broken cvs command line about cvs comamnd(checkout: $CMD)): $original" 2>&1
	return 1
    fi

    if test -z "$REPO"; then
	echo "no repository" 2>&1
	return 1
    fi

    if test "x$(echo $REPO | sed -e 's/[^:]//g')" != "x::::"; then
	echo "broken repo specification: $REPO" 2>&1
	return 1
    fi

    
    if test "x$1" = "x-P"; then
	shift 1
    fi

    local dflags=$1
    PACKAGE=$2
    shift 2

    if test \( -n "${dflags}" \) -a \( "${dflags}" != "-d" \); then
	echo "broken cvs command line about directory specification(-d: ${dflags}): $original" 2>&1
	return 1
    fi

    if test -z "$PACKAGE"; then
	echo "no packagedir" 2>&1
	return 1
    fi

    if test "x$1" = "x-P"; then
	shift 1
    fi

    MODULE=$1
    if test -z "$MODULE"; then
	echo "no module" 2>&1
	return 1
    fi

    return 0
}

function cvs_update
{
    which cvs > /dev/null && cvs update -d
}

function cvs_rebirth
{
    local cvs_root=
    local cvs_repo=
    local top_dir=`pwd`
    local cvs_dir=$(basename  ${top_dir})
    local cvs_root_rx=
    local cvs_pass=

    (cd CVS; 
	if test -f Root; then
	    cvs_root=`cat Root`
	else
	    echo "cannot find cvs Root file" 1>&2
	    pwd 1>&2
	    return 1
	fi

	if test -f Repository; then
	    cvs_repo=`cat Repository`
	else
	    echo "cannot find cvs Repository file" 1>&2
	    pwd 1>&2
	    return 1
	fi


	echo "# [0] ${top_dir}"

	cvs_pass=$(echo $cvs_repo | sed -n -e 's/.*:\([^:]\+\)@.*/\1/p')

	if test -z "$cvs_pass"; then
	    cvs_root_rx=`echo ${cvs_root} | sed -e 's|\(.*\):/\(.*\)|\1:[0-9]*/\2|'`
	    cvs_pass=`grep "${cvs_root_rx}" ~/.cvspass 2>/dev/null`
	    if [ $? == 0 ]; then
		cat <<EOF
fgrep '${cvs_pass}' ~/.cvspass > /dev/null 2>&1 \\
|| echo '${cvs_pass}' >> ~/.cvspass
EOF
            else
		echo "# [1] cannot find password entry for ${top_dir}"
	    fi
	fi

	echo cvs -d"${cvs_root}" checkout -P -d ${cvs_dir} ${cvs_repo}
	return 0
	)
}

: lcopy-cvs.bash ends here