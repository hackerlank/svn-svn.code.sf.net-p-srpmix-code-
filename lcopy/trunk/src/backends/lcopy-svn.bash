function svn_p
{
    test -d .svn
}

function svn_checkout
{

    local repo=$1
    local dir=$2
    
    
    echo svn checkout "$repo" "$dir"
}

function svn_checkout_parse_cmdline
{
    VCS=$1
    CMD=$2
    REPO=$3
    PACKAGE=$4
    
    if test "x$VCS" != xsvn; then
	echo "Wrong vcs: $VCS" 2>&1
	return 1
    fi

    if test \( "x$CMD" != "xcheckout" \) -a \
	    \( "x$CMD" != "xco"    \); then
	echo "broken svn command line: $@" 2>&1
	return 1
    fi

    if test -z "$REPO"; then
	echo "no repository" 2>&1
	return 1
    fi

    if echo "$REPO" | grep -E -e "^http[s]?://" > /dev/null 2>&1; then
	:
    elif echo "$REPO" | grep -E -e "^svn://" > /dev/null 2>&1; then
	# e.g.
        # svn co svn://svn@svn.a-k-r.org/akr/wfo/trunk wfo
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

function svn_checkout_print_usage
{
    echo "	" svn "checkout|co" REPOS PACKAGEDIR
    echo "	" "REPOS => http://..., https://..., or svn://..."
}

function svn_update
{
    which svn > /dev/null && svn update
}


function svn_rebirth
{
    local svn_info=`svn info`
    if test $? != 0; then
	echo "fail in 'svn info' invocation" 1>&2
	pwd 1>&2
	return 1
    fi

    local svn_url=`echo "$svn_info" | grep 'URL: ' |  sed -e 's/URL: //'`
    if test "x${svn_url}" = x; then
	echo "cannot find URL line in svn_info output" 1>&2
	pwd 1>&2
	return 1
    fi
    
    local top_dir=`pwd`
    local svn_dir=$(basename ${top_dir})

    echo "# [0] ${top_dir}"
    echo "svn checkout ${svn_url} ${svn_dir}"
    return 0
}

function svn_to_pkg
{
    echo subversion
}

: lcopy-svn.bash ends here
