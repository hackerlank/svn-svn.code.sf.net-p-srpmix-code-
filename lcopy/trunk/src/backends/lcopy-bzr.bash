#
# Bazzar NG
#

function bzr_p
{
    test -d .bzr
}

function bzr_checkout
{
    local repo=$1
    local dir=$2

    echo bzr branch "$repo" "$dir"
}

function bzr_checkout_parse_cmdline
{
    VCS=$1
    CMD=$2
    REPO=$3
    PACKAGE=$4

    if test "x$VCS" != xbzr; then
	echo "wrong vcs: $VCS" 2>&1
	return 1
    fi

    if test \( -z "$CMD"          \) -a    \
            \( "$CMD" != branch \) ; then
	echo "broken bzr command line: $@" 2>&1
	return 1
    fi

    if test -z "$REPO"; then
	echo "no repository" 2>&1
	return 1
    fi

    if echo "$REPO" | grep -E -e "^http[s]?://" > /dev/null 2>&1; then
	:
    else
	echo "unknown repository specification: $REPO" 2>&1
	return 1
    fi
 
    if test -z "$PACKAGE"; then
	echo "no packagedir" 2>&1
	return 1
    fi

    return 0
}

function bzr_checkout_print_usage
{
    echo "	" bar branch LOCATION PACKAGEDIR
}

function bzr_update
{
    which bzr > /dev/null && bzr update
}

function bzr_rebirth
{
    local bzr_location=`bzr info | grep -e 'parent branch:' | sed -e 's/  parent branch: //'`
    echo bzr branch ${bzr_location} `pwd`
}

: lcopy-bzr.bash ends here