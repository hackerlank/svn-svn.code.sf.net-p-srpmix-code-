function hg_p
{
    test -d .hg
}


function hg_checkout
{

    local repo=$1
    local dir=$2
    
    echo hg clone "$repo" "$dir"
}

function hg_checkout_print_usage
{
    echo "	" hg clone REPOS PACKAGEDIR
}

function hg_checkout_parse_cmdline
{
    VCS=$1
    CMD=$2
    REPO=$3
    PACKAGE=$4

    if test "x$VCS" != xhg; then
	echo "wrong vcs: $VCS" 2>&1
	return 1
    fi

    if test \( -z "$CMD"          \) -a    \
            \( "$CMD" != clone \) ; then
	echo "broken hg command line: $@" 2>&1
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
 
# TODO
#    if test "x$(echo $REPO | sed -e 's/[^:]//g')" != "x::::"; then
#	echo "broken repo specification: $REPO" 2>&1
#	return 1
#    fi

    if test -z "$PACKAGE"; then
	echo "no packagedir" 2>&1
	return 1
    fi

    return 0
}


function hg_update
{
    which hg > /dev/null && hg update
} 

function hg_rebirth
{
    local hg_path=`hg showconfig -u paths.default 2> /dev/null`
    if test $? != 0; then
	echo "fail in 'hg showconfig' invocation" 1>&2
	pwd 1>&2
	return 1
    fi

    local top_dir=`pwd`
    echo "# [0] ${top_dir}"
    echo "hg clone ${hg_path} `basename ${top_dir}`"
    return 0
}

function hg_to_pkg
{
    echo mercurial
}

: lcopy-hg.bash ends here
